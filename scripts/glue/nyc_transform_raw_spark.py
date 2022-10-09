import sys
from typing import Any, Dict

from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession


def parse_arguments() -> Dict[str, Any]:
    return getResolvedOptions(sys.argv, ["nyc_source", "nyc_destination"])


def main():
    spark = SparkSession.builder.getOrCreate()
    args = parse_arguments()

    data_nyc = (
        spark.read.option("delimiter", ",")
        .option("header", "true")
        .csv(args["nyc_source"])
    )
    data_nyc_dropped = data_nyc.drop("congestion_surcharge")
    data_nyc_dropped.write.mode("overwrite").parquet(args["nyc_destination"])


if __name__ == "__main__":
    main()
