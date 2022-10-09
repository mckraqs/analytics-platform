provider "aws" {
  region = var.resources_region
}

module "storage" {
  source               = "./../modules/storage"
  environment          = var.environment
  resources_region     = var.resources_region
  airflow_code_zip     = "./../../plugins.zip"
  airflow_requirements = "./../../requirements.txt"
}

module "network" {
  source               = "./../modules/network"
  region               = var.resources_region
  availability_zones   = ["eu-central-1a", "eu-central-1b"]
  vpc_cidr             = "10.192.0.0/16"
  public_subnet1_cidr  = "10.192.10.0/24"
  public_subnet2_cidr  = "10.192.11.0/24"
  private_subnet1_cidr = "10.192.20.0/24"
  private_subnet2_cidr = "10.192.21.0/24"
}

module "iam" {
  source           = "./../modules/iam"
  environment      = var.environment
  resources_region = var.resources_region
  account_id       = var.account_id
}

module "managed_airflow" {
  source                     = "./../modules/managed_airflow"
  environment                = var.environment
  resources_region           = var.resources_region
  airflow_version            = "2.2.2"
  airflow_bucket_arn         = module.storage.airflow_bucket_arn
  airflow_bucket_url         = module.storage.airflow_bucket_id
  airflow_private_subnets    = module.network.airflow_private_subnets
  airflow_vpc_sg             = module.network.airflow_security_group_ids
  airflow_execution_role_arn = module.iam.airflow_execution_role_arn
}

module "redshift" {
  source                           = "./../modules/redshift"
  environment                      = var.environment
  redshift_main_cluster_subnet_ids = module.network.airflow_public_subnets
  redshift_node_type               = "dc2.large"
  redshift_number_of_nodes         = 2
  redshift_master_username         = "admin"        # Should be used as a secret, e.g. hashed environment variable
  redshift_master_password         = "admin1231231" # Should be used as a secret, e.g. hashed environment variable
  redshift_role_arn                = module.iam.redshift_execution_role_arn
  redshift_vpc_security_group_ids  = module.network.airflow_security_group_ids
}

module "glue" {
  source               = "./../modules/glue"
  environment          = var.environment
  glue_assume_role_arn = module.iam.glue_execution_role_arn
  data_bucket_url      = module.storage.data_bucket_id
  airflow_bucket_url   = module.storage.airflow_bucket_id
  nyc_glue_script_file = "scripts/glue/nyc_transform_raw_spark.py"
}

terraform {
  backend "s3" {
    key            = "prod/modules/storage/terraform.tfstate"
    bucket         = "mpolakowski-showcase-ap-tf"
    region         = "eu-central-1"
    dynamodb_table = "mpolakowski-ap-showcase-tf-state-lock-table" # LockID as String for partition key
    encrypt        = true
  }
}
