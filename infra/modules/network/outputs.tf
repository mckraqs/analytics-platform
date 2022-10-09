output "airflow_private_subnets" {
  value = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

output "airflow_public_subnets" {
  value = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "airflow_security_group_ids" {
  value = [aws_security_group.security_group.id]
}

output "vpc_security_group" {
  value = aws_security_group.security_group.id
}
