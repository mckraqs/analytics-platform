# S3 bucket for data
resource "aws_s3_bucket" "s3_bucket_data" {
  bucket = format("mpolakowski-showcase-ap-data-%s", var.environment)

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_old_data" {
  bucket = aws_s3_bucket.s3_bucket_data.bucket

  rule {
    id = "rule-old-data-lifecycle"

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_data_access_block" {
  bucket = aws_s3_bucket.s3_bucket_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket for Airflow configuration
resource "aws_s3_bucket" "s3_bucket_airflow" {
  bucket = format("mpolakowski-showcase-ap-airflow-%s", var.environment)

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_airflow_access_block" {
  bucket = aws_s3_bucket.s3_bucket_airflow.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "s3_subdirectory_data_raw" {
  bucket       = aws_s3_bucket.s3_bucket_data.id
  key          = "raw/"
  content_type = "applications/directory"
}

resource "aws_s3_bucket_object" "s3_subdirectory_data_staging" {
  bucket       = aws_s3_bucket.s3_bucket_data.id
  key          = "staging/"
  content_type = "applications/directory"
}

resource "aws_s3_bucket_object" "s3_subdirectory_data_gold" {
  bucket       = aws_s3_bucket.s3_bucket_data.id
  key          = "gold/"
  content_type = "applications/directory"
}

resource "aws_s3_bucket_object" "s3_subdirectory_data_raw_nyc" {
  bucket       = aws_s3_bucket.s3_bucket_data.id
  key          = "raw/nyc/"
  content_type = "applications/directory"
}

# Commented out as this folders are created by Spark jobs by Glue and EMR respectively
#resource "aws_s3_bucket_object" "s3_subdirectory_data_staging_nyc" {
#  bucket       = aws_s3_bucket.s3_bucket_data.id
#  key          = "staging/nyc/"
#  content_type = "applications/directory"
#}
#
#resource "aws_s3_bucket_object" "s3_subdirectory_data_gold_nyc" {
#  bucket       = aws_s3_bucket.s3_bucket_data.id
#  key          = "gold/nyc/"
#  content_type = "applications/directory"
#}

resource "aws_s3_bucket_object" "s3_subdirectory_airflow_dags" {
  bucket       = aws_s3_bucket.s3_bucket_airflow.id
  key          = "dags/"
  content_type = "applications/directory"
}

resource "aws_s3_bucket_object" "s3_subdirectory_airflow_plugins" {
  bucket       = aws_s3_bucket.s3_bucket_airflow.id
  key          = "plugins/"
  content_type = "applications/directory"
}

resource "aws_s3_bucket_object" "s3_subdirectory_airflow_requirements" {
  bucket       = aws_s3_bucket.s3_bucket_airflow.id
  key          = "requirements/"
  content_type = "applications/directory"
}

resource "aws_s3_bucket_object" "s3_subdirectory_airflow_scripts" {
  bucket       = aws_s3_bucket.s3_bucket_airflow.id
  key          = "scripts/"
  content_type = "applications/directory"
}

resource "aws_s3_bucket_object" "s3_subdirectory_airflow_logs" {
  bucket       = aws_s3_bucket.s3_bucket_airflow.id
  key          = "logs/"
  content_type = "applications/directory"
}

resource "aws_s3_bucket_object" "s3_subdirectory_airflow_scripts_glue" {
  bucket       = aws_s3_bucket.s3_bucket_airflow.id
  key          = "scripts/glue/"
  content_type = "applications/directory"
}

resource "aws_s3_bucket_object" "s3_subdirectory_airflow_scripts_emr" {
  bucket       = aws_s3_bucket.s3_bucket_airflow.id
  key          = "scripts/emr/"
  content_type = "applications/directory"
}

resource "aws_s3_bucket_object" "s3_subdirectory_airflow_logs_emr" {
  bucket       = aws_s3_bucket.s3_bucket_airflow.id
  key          = "logs/emr/"
  content_type = "applications/directory"
}

resource "aws_s3_bucket_object" "s3_plugins_airflow_code" {
  bucket = aws_s3_bucket.s3_bucket_airflow.id
  key    = "plugins/plugins.zip"
  source = var.airflow_code_zip
}

resource "aws_s3_bucket_object" "s3_requirements_airflow" {
  bucket = aws_s3_bucket.s3_bucket_airflow.id
  key    = "requirements/requirements.txt"
  source = var.airflow_requirements
}
