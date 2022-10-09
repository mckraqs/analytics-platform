output "airflow_bucket_id" {
  value = aws_s3_bucket.s3_bucket_airflow.id
}

output "airflow_bucket_arn" {
  value = aws_s3_bucket.s3_bucket_airflow.arn
}

output "data_bucket_id" {
  value = aws_s3_bucket.s3_bucket_data.id
}