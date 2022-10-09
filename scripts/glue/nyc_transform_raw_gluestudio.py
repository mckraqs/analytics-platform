# Code copy-pasted from AWS Glue Studio after creating whole pipeline

import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.gluetypes import *
from awsglue import DynamicFrame


def _find_null_fields(ctx, schema, path, output, nullStringSet, nullIntegerSet, frame):
    if isinstance(schema, StructType):
        for field in schema:
            new_path = path + "." if path != "" else path
            output = _find_null_fields(
                ctx,
                field.dataType,
                new_path + field.name,
                output,
                nullStringSet,
                nullIntegerSet,
                frame,
            )
    elif isinstance(schema, ArrayType):
        if isinstance(schema.elementType, StructType):
            output = _find_null_fields(
                ctx,
                schema.elementType,
                path,
                output,
                nullStringSet,
                nullIntegerSet,
                frame,
            )
    elif isinstance(schema, NullType):
        output.append(path)
    else:
        x, distinct_set = frame.toDF(), set()
        for i in x.select(path).distinct().collect():
            distinct_ = i[path.split(".")[-1]]
            if isinstance(distinct_, list):
                distinct_set |= set(
                    [
                        item.strip() if isinstance(item, str) else item
                        for item in distinct_
                    ]
                )
            elif isinstance(distinct_, str):
                distinct_set.add(distinct_.strip())
            else:
                distinct_set.add(distinct_)
        if isinstance(schema, StringType):
            if distinct_set.issubset(nullStringSet):
                output.append(path)
        elif (
            isinstance(schema, IntegerType)
            or isinstance(schema, LongType)
            or isinstance(schema, DoubleType)
        ):
            if distinct_set.issubset(nullIntegerSet):
                output.append(path)
    return output


def drop_nulls(
    glueContext, frame, nullStringSet, nullIntegerSet, transformation_ctx
) -> DynamicFrame:
    nullColumns = _find_null_fields(
        frame.glue_ctx, frame.schema(), "", [], nullStringSet, nullIntegerSet, frame
    )
    return DropFields.apply(
        frame=frame, paths=nullColumns, transformation_ctx=transformation_ctx
    )


args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node S3 bucket
S3bucket_node1 = glueContext.create_dynamic_frame.from_catalog(
    database="data-catalog-prod",
    table_name="prod-raw-nyc",
    transformation_ctx="S3bucket_node1",
)

# Script generated for node ApplyMapping
ApplyMapping_node2 = ApplyMapping.apply(
    frame=S3bucket_node1,
    mappings=[
        ("vendorid", "long", "vendorid", "long"),
        ("lpep_pickup_datetime", "string", "lpep_pickup_datetime", "string"),
        ("lpep_dropoff_datetime", "string", "lpep_dropoff_datetime", "string"),
        ("store_and_fwd_flag", "string", "store_and_fwd_flag", "string"),
        ("ratecodeid", "long", "ratecodeid", "long"),
        ("pulocationid", "long", "pulocationid", "long"),
        ("dolocationid", "long", "dolocationid", "long"),
        ("passenger_count", "long", "passenger_count", "long"),
        ("trip_distance", "double", "trip_distance", "double"),
        ("fare_amount", "double", "fare_amount", "double"),
        ("extra", "double", "extra", "double"),
        ("mta_tax", "double", "mta_tax", "double"),
        ("tip_amount", "double", "tip_amount", "double"),
        ("tolls_amount", "double", "tolls_amount", "double"),
        ("ehail_fee", "string", "ehail_fee", "string"),
        ("improvement_surcharge", "double", "improvement_surcharge", "double"),
        ("total_amount", "double", "total_amount", "double"),
        ("payment_type", "long", "payment_type", "long"),
        ("trip_type", "long", "trip_type", "long"),
        ("congestion_surcharge", "double", "congestion_surcharge", "double"),
    ],
    transformation_ctx="ApplyMapping_node2",
)

# Script generated for node Drop Null Fields
DropNullFields_node1664819610118 = drop_nulls(
    glueContext,
    frame=ApplyMapping_node2,
    nullStringSet={""},
    nullIntegerSet={},
    transformation_ctx="DropNullFields_node1664819610118",
)

# Script generated for node S3 bucket
S3bucket_node3 = glueContext.write_dynamic_frame.from_options(
    frame=DropNullFields_node1664819610118,
    connection_type="s3",
    format="glueparquet",
    connection_options={
        "path": "s3://mpolakowski-showcase-ap-data-prod/staging/nyc/",
        "partitionKeys": [],
    },
    format_options={"compression": "snappy"},
    transformation_ctx="S3bucket_node3",
)

job.commit()
