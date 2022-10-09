from datetime import timedelta

import airflow
from airflow import DAG
from airflow.providers.amazon.aws.sensors.s3_key import S3KeySensor
from airflow.providers.amazon.aws.sensors.emr_step import EmrStepSensor
from airflow.providers.amazon.aws.operators.glue_crawler import AwsGlueCrawlerOperator
from airflow.providers.amazon.aws.operators.glue import AwsGlueJobOperator
from airflow.providers.amazon.aws.operators.emr_create_job_flow import (
    EmrCreateJobFlowOperator,
)
from airflow.providers.amazon.aws.operators.emr_terminate_job_flow import (
    EmrTerminateJobFlowOperator,
)
from airflow.providers.amazon.aws.operators.emr_add_steps import EmrAddStepsOperator
from airflow.providers.amazon.aws.transfers.s3_to_redshift import S3ToRedshiftOperator

# Spark EMR job definition
execution_date = "{{ execution_date }}"
S3_AIRFLOW_BUCKET_NAME = "mpolakowski-showcase-ap-airflow-prod"
S3_DATA_BUCKET_NAME = "mpolakowski-showcase-ap-data-prod"
S3_URI = f"s3://{S3_AIRFLOW_BUCKET_NAME}/scripts/emr/"
JOB_FLOW_OVERRIDES = {
    "Name": "data-processing-nyc-" + execution_date,
    "ReleaseLabel": "emr-5.29.0",
    "LogUri": f"s3://{S3_AIRFLOW_BUCKET_NAME}/logs/emr/",
    "Instances": {
        "Ec2SubnetId": "subnet-0ce732338894d0123",  # AWS VPC Subnet where to execute EMR jobs
        "InstanceGroups": [
            {
                "Name": "Master nodes",
                "InstanceRole": "MASTER",
                "InstanceType": "r3.2xlarge",
                "InstanceCount": 1,
            },
            {
                "Name": "Slave nodes",
                "InstanceRole": "CORE",
                "InstanceType": "r3.2xlarge",
                "InstanceCount": 2,
            },
        ],
        "TerminationProtected": False,
        "KeepJobFlowAliveWhenNoSteps": True,
    },
}
SPARK_STEPS = [
    {
        "Name": "Copy EMR script files",
        "ActionOnFailure": "CANCEL_AND_WAIT",
        "HadoopJarStep": {
            "Jar": "command-runner.jar",
            "Args": ["aws", "s3", "cp", "--recursive", S3_URI, "/home/hadoop/"],
        },
    },
    {
        "Name": "Run Spark",
        "ActionOnFailure": "CANCEL_AND_WAIT",
        "HadoopJarStep": {
            "Jar": "command-runner.jar",
            "Args": [
                "spark-submit",
                "/home/hadoop/nyc_aggregate_emr.py",
                f"s3://{S3_DATA_BUCKET_NAME}/staging/nyc",
                f"s3://{S3_DATA_BUCKET_NAME}/gold/nyc",
            ],
        },
    },
]

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": airflow.utils.dates.days_ago(1),
    "retries": 0,
    "retry_delay": timedelta(minutes=2),
    "provide_context": True,
    "email": ["airflow@example.com"],
    "email_on_failure": False,
    "email_on_retry": False,
}


with DAG(
    "prepare_data_nyc",
    default_args=default_args,
    dagrun_timeout=timedelta(hours=2),
    schedule_interval="0 0 * * *",
) as dag:

    s3_nyc_sensor = S3KeySensor(
        task_id="s3_sensor_nyc",
        aws_conn_id="aws_default",
        bucket_key=f"s3://{S3_DATA_BUCKET_NAME}/raw/nyc/*.csv",
        wildcard_match=True,
    )

    glue_crawler = AwsGlueCrawlerOperator(
        task_id="crawl_data_nyc",
        aws_conn_id="aws_default",
        config={"Name": "crawler-nyc-prod"},
    )

    glue_job = AwsGlueJobOperator(
        task_id="process_to_staging_nyc",
        aws_conn_id="aws_default",
        job_name="Transform NYC - prod - PySpark",
        script_args={
            "--nyc_source": f"s3://{S3_DATA_BUCKET_NAME}/raw/nyc/",
            "--nyc_destination": f"s3://{S3_DATA_BUCKET_NAME}/staging/nyc/",
        },
    )

    emr_jobflow_creator = EmrCreateJobFlowOperator(
        task_id="create_emr_jobflow",
        aws_conn_id="aws_default",
        job_flow_overrides=JOB_FLOW_OVERRIDES,
    )

    emr_addstep = EmrAddStepsOperator(
        task_id="add_emr_step",
        aws_conn_id="aws_default",
        job_flow_id="{{ ti.xcom_pull('create_emr_jobflow', key='return_value') }}",
        steps=SPARK_STEPS,
    )

    emr_step_sensor = EmrStepSensor(
        task_id="emr_step_sensor",
        aws_conn_id="aws_default",
        job_flow_id="{{ ti.xcom_pull('create_emr_jobflow', key='return_value') }}",
        step_id="{{ ti.xcom_pull('add_emr_step', key='return_value')[0] }}",
    )

    remove_jobflow = EmrTerminateJobFlowOperator(
        task_id="terminate_jobflow",
        aws_conn_id="aws_default",
        job_flow_id="{{ ti.xcom_pull('create_emr_jobflow', key='return_value') }}",
    )

    s3_to_redshift = S3ToRedshiftOperator(
        task_id="load_nyc_to_redshift",
        schema="nyc",
        table="main_data",
        s3_bucket=S3_DATA_BUCKET_NAME,
        s3_key="gold/nyc/",
        method="REPLACE",
        copy_options=["FORMAT AS PARQUET"],
    )

    (
        s3_nyc_sensor
        >> glue_crawler
        >> glue_job
        >> emr_jobflow_creator
        >> emr_addstep
        >> emr_step_sensor
        >> remove_jobflow
        >> s3_to_redshift
    )
