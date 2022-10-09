variable "region" {
  type = string
}

variable "availability_zones" {
  description = "List of application's region availability zones"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "Please enter the IP range (CIDR notation) for this VPC"
  type        = string
}


variable "public_subnet1_cidr" {
  description = "Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone"
  type        = string
}


variable "public_subnet2_cidr" {
  description = "Please enter the IP range (CIDR notation) for the public subnet in the second Availability Zone"
  type        = string
}


variable "private_subnet1_cidr" {
  description = "Please enter the IP range (CIDR notation) for the private subnet in the first Availability Zone"
  type        = string
}


variable "private_subnet2_cidr" {
  description = "Please enter the IP range (CIDR notation) for the private subnet in the second Availability Zone"
  type        = string
}
