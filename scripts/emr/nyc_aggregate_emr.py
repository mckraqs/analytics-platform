import sys
import logging
from pyspark.sql import SparkSession
import pyspark.sql.functions as F


if __name__ == "__main__":
    if len(sys.argv) != 3:
        logging.log(
            logging.ERROR,
            """
        Usage: nyc_aggregate_emr.py <s3_input_path> <s3_output_path> 
        """,
        )
        sys.exit(-1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    spark = SparkSession.builder.appName("Prepare data - NYC").getOrCreate()

    sc = spark.sparkContext

    df = spark.read.parquet(input_path)
    df_out = df.groupBy("pulocationid", "trip_type", "payment_type").agg(
        F.sum("fare_amount").alias("total_fare_amount")
    )

    df_out.printSchema()
    df_out.show(5, False)

    df_out.coalesce(1).write.mode("overwrite").parquet(output_path)

    spark.stop()
