data "aws_vpc" "kanda" {
  id = "vpc-026cc78e3a34ee662"
}

resource "aws_security_group" "kanda-ec2" {
  name = "${local.name_prefix}-ec2-sg"
  vpc_id = data.aws_vpc.kanda.id
  ingress {
    protocol  = "tcp"
    cidr_blocks = [data.aws_vpc.kanda.cidr_block]
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
  vpc_id      = data.aws_vpc.kanda.id
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
  vpc_id      = data.aws_vpc.kanda.id
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

data "aws_subnet" "kanda-1" {
  id = "subnet-01903e61d2139ab94"
}

data "aws_subnet" "kanda-2" {
  id = "subnet-0b5f1b84133fef3be"
}
