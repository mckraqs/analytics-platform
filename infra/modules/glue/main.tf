resource "aws_glue_catalog_database" "data_catalog_database" {
  name = format("data-catalog-%s", var.environment)
}

resource "aws_glue_crawler" "data_catalog_crawler_nyc" {
  database_name = aws_glue_catalog_database.data_catalog_database.name
  name          = format("crawler-nyc-%s", var.environment)
  role          = var.glue_assume_role_arn
  table_prefix  = format("%s-raw-", var.environment)

  s3_target {
    path = format("s3://%s/raw/nyc", var.data_bucket_url)
  }
}

resource "aws_cloudwatch_log_group" "log_group_glue_nyc" {
  name              = format("log_group_glue_nyc-%s", var.environment)
  retention_in_days = 30
}

resource "aws_glue_job" "glue_job_nyc" {
  name              = format("Transform NYC - %s - PySpark", var.environment)
  role_arn          = var.glue_assume_role_arn
  glue_version      = "2.0"
  number_of_workers = 2
  worker_type       = "Standard"
  timeout           = 30
  max_retries       = 0

  command {
    script_location = format("s3://%s/%s", var.airflow_bucket_url, var.nyc_glue_script_file)
  }

  default_arguments = {
    "--nyc_source"                       = ""
    "--nyc_destination"                  = ""
    "--job-language"                     = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.log_group_glue_nyc.name
  }
}