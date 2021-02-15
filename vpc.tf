resource "aws_vpc" "kanda" {
  cidr_block       = "10.2.0.0/26"
  instance_tenancy = "default"

  tags = local.common_tags
}

resource "aws_default_security_group" "kanda" {
  vpc_id = aws_vpc.kanda.id

  ingress {
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port   = 0
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
  cidr_block = "10.2.0.0/27"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = local.common_tags
}

resource "aws_subnet" "kanda-2" {
  vpc_id     = aws_vpc.kanda.id
  cidr_block = "10.2.0.32/27"
  availability_zone = "us-east-1b"
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
