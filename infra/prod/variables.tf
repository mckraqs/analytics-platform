variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "resources_region" {
  description = "Default region for all resources"
  type        = string
  default     = "eu-central-1"
}

variable "account_id" {
  description = "Account ID"
  type        = string
  default     = "00123456789"
}