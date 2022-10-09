resource "aws_mwaa_environment" "mwaa_environment" {
  name               = format("showcase-ap-airflow-%s", var.environment)
  airflow_version    = var.airflow_version
  execution_role_arn = var.airflow_execution_role_arn

  source_bucket_arn    = var.airflow_bucket_arn
  dag_s3_path          = "dags/"
  plugins_s3_path      = "plugins/plugins.zip"
  requirements_s3_path = "requirements/requirements.txt"

  environment_class = "mw1.medium"
  min_workers       = 1
  max_workers       = 4
  schedulers        = 2

  webserver_access_mode = "PUBLIC_ONLY" # to skip setting up special extra VPN or VPC connection
  network_configuration {
    security_group_ids = var.airflow_vpc_sg
    subnet_ids         = var.airflow_private_subnets
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }

  airflow_configuration_options = {
    "core.enable_xcom_pickling" = "true"
  }
}