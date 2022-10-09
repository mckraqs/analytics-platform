variable "environment" {
  description = "Environment name"
  type        = string
}

variable "resources_region" {
  description = "Default region for all resources"
  type        = string
}

variable "airflow_code_zip" {
  description = "Zip file path containing code for Airflow functionalities"
  type        = string
}

variable "airflow_requirements" {
  description = "File path containing Python environment requirements for Airflow"
  type        = string
}
