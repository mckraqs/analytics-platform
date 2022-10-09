variable "environment" {
  description = "Environment name"
  type        = string
}

variable "resources_region" {
  description = "Default region for all resources"
  type        = string
}

variable "airflow_version" {
  description = "Airflow version for AWS MWAA environment"
  type        = string
}

variable "airflow_bucket_arn" {
  description = "Airflow AWS S3 bucket ARN"
  type        = string
}

variable "airflow_bucket_url" {
  description = "Airflow AWS S3 bucket URL"
  type        = string
}

variable "airflow_private_subnets" {
  description = "Private subnets necessary to create AWS MWAA environment"
  type        = list(string)
}

variable "airflow_vpc_sg" {
  description = "VPC security group for AWS MWAA environment"
  type        = list(string)
}

variable "airflow_execution_role_arn" {
  description = "AWS Role ARN for Airflow environment execution"
  type        = string
}