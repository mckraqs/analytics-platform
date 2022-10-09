output "airflow_execution_role_arn" {
  value = aws_iam_role.mwaa_assume_role.arn
}

output "redshift_execution_role_arn" {
  value = aws_iam_role.redshift_assume_role.arn
}

output "glue_execution_role_arn" {
  value = aws_iam_role.glue_assume_role.arn
}