resource "aws_redshift_subnet_group" "main_cluster_subnet_group" {
  name       = format("showcase-ap-main-cluster-subnet-group-%s", var.environment)
  subnet_ids = var.redshift_main_cluster_subnet_ids
}

resource "aws_redshift_cluster" "main_cluster" {
  cluster_identifier = format("showcase-ap-main-cluster-%s", var.environment)

  iam_roles            = [var.redshift_role_arn]
  default_iam_role_arn = var.redshift_role_arn

  node_type           = var.redshift_node_type
  number_of_nodes     = var.redshift_number_of_nodes
  port                = 5439
  skip_final_snapshot = true

  master_username = var.redshift_master_username
  master_password = var.redshift_master_password
  database_name   = "dev"

  cluster_subnet_group_name = aws_redshift_subnet_group.main_cluster_subnet_group.name
  vpc_security_group_ids    = var.redshift_vpc_security_group_ids
}
