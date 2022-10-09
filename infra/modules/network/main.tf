resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_vpc_endpoint" "vpc_storage_gateway" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = format("com.amazonaws.%s.s3", var.region)
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_vpc.vpc.default_route_table_id]
}

resource "aws_internet_gateway" "igw" {
  depends_on = [aws_vpc.vpc]

  vpc_id = aws_vpc.vpc.id
}


resource "aws_subnet" "public_subnet_1" {
  depends_on = [aws_vpc.vpc]

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zones[0]
  cidr_block              = var.public_subnet1_cidr
  map_public_ip_on_launch = true
}


resource "aws_subnet" "public_subnet_2" {
  depends_on = [aws_vpc.vpc]

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zones[1]
  cidr_block              = var.public_subnet2_cidr
  map_public_ip_on_launch = true
}


resource "aws_subnet" "private_subnet_1" {
  depends_on = [aws_vpc.vpc]

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zones[0]
  cidr_block              = var.private_subnet1_cidr
  map_public_ip_on_launch = false
}


resource "aws_subnet" "private_subnet_2" {
  depends_on = [aws_vpc.vpc]

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zones[1]
  cidr_block              = var.private_subnet2_cidr
  map_public_ip_on_launch = false
}


resource "aws_eip" "elastic_ip_1" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "elastic_ip_2" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.elastic_ip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.elastic_ip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "route_table_private_1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }
}

resource "aws_route_table" "route_table_private_2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
  }
}

resource "aws_route_table_association" "rta_public_1" {
  route_table_id = aws_route_table.route_table_public.id
  subnet_id      = aws_subnet.public_subnet_1.id
}

resource "aws_route_table_association" "rta_public_2" {
  route_table_id = aws_route_table.route_table_public.id
  subnet_id      = aws_subnet.public_subnet_2.id
}

resource "aws_route_table_association" "rta_private_1" {
  route_table_id = aws_route_table.route_table_private_1.id
  subnet_id      = aws_subnet.private_subnet_1.id
}

resource "aws_route_table_association" "rta_private_2" {
  route_table_id = aws_route_table.route_table_private_2.id
  subnet_id      = aws_subnet.private_subnet_2.id
}


resource "aws_security_group" "security_group" {
  name        = "mwaa-security-group"
  description = "Security group with a self-referencing inbound rule."
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "sg_rule_egress_tcp" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "sg_rule_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [aws_vpc_endpoint.vpc_storage_gateway.prefix_list_id]
  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "sg_rule_ingress_redshift" {
  type                     = "ingress"
  from_port                = 5439
  to_port                  = 5439
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.security_group.id
  security_group_id        = aws_security_group.security_group.id
}

# Extra (local) IP ingress rule for local development and scheduling Redshift commands
# Could be some CIDR block that represents some other specific subnet
resource "aws_security_group_rule" "sg_rule_ingress_redshift_localip" {
  type              = "ingress"
  from_port         = 5439
  to_port           = 5439
  protocol          = "tcp"
  cidr_blocks       = ["xxx.yyy.zzz.qqq/32"]
  security_group_id = aws_security_group.security_group.id
}