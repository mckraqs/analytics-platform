variable "environment" {
  description = "Environment name"
  type        = string
}

variable "glue_assume_role_arn" {
  type = string
}

variable "data_bucket_url" {
  type = string
}

variable "airflow_bucket_url" {
  type = string
}

variable "nyc_glue_script_file" {
  type = string
}