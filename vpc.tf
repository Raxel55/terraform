resource "aws_vpc" "kanda" {
  cidr_block       = var.vpc_cidr_block.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = local.common_tags
}

resource "aws_security_group" "kanda-ec2" {
  name = "${local.name_prefix}-ec2-sg"
  vpc_id = aws_vpc.kanda.id
  ingress {
    protocol  = "tcp"
    cidr_blocks = [aws_vpc.kanda.cidr_block]
    from_port = 80
    to_port   = 80
  }
  ingress {
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port   = 22
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

resource "aws_security_group" "kanda-rds" {
  name        = "${local.name_prefix}-rds-sg"
  vpc_id      = aws_vpc.kanda.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

resource "aws_security_group" "kanda-alb" {
  name        = "${local.name_prefix}-alb-sg"
  vpc_id      = aws_vpc.kanda.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

resource "aws_subnet" "kanda-1" {
  vpc_id     = aws_vpc.kanda.id
  cidr_block = var.vpc_cidr_block.subnet_1_cidr
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = local.common_tags
}

resource "aws_subnet" "kanda-2" {
  vpc_id     = aws_vpc.kanda.id
  cidr_block = var.vpc_cidr_block.subnet_2_cidr
  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = local.common_tags
}

resource "aws_internet_gateway" "kanda" {
  vpc_id = aws_vpc.kanda.id
  tags = local.common_tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.kanda.id
  tags = local.common_tags
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.kanda.id
  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "kanda-1" {
  subnet_id      = aws_subnet.kanda-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "kanda-2" {
  subnet_id      = aws_subnet.kanda-2.id
  route_table_id = aws_route_table.public.id
}
