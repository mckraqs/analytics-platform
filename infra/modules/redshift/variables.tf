variable "environment" {
  description = "Environment name"
  type        = string
}

variable "redshift_main_cluster_subnet_ids" {
  type = list(string)
}

variable "redshift_node_type" {
  type = string
}

variable "redshift_number_of_nodes" {
  type = string
}

variable "redshift_master_username" {
  type = string
}

variable "redshift_master_password" {
  type = string
}

variable "redshift_role_arn" {
  type = string
}

variable "redshift_vpc_security_group_ids" {
  type = list(string)
}
