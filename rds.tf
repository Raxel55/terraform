resource "aws_db_instance" "kanda" {
  allocated_storage    = 200
  db_subnet_group_name = aws_db_subnet_group.kanda.name
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.medium"
  identifier           = "${local.name_prefix}-db"
  name                 = var.database.name
  username             = var.database.user
  password             = var.database.password
  parameter_group_name = "kanda-mysql"
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.kanda-rds.id]
  tags = local.common_tags
}

resource "aws_db_parameter_group" "kanda" {
  name   = "${local.name_prefix}-db-parameter-group"
  family = "mysql5.7"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
  tags = local.common_tags
}

resource "aws_db_subnet_group" "kanda" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = [aws_subnet.kanda-1.id, aws_subnet.kanda-2.id]
  tags = local.common_tags
}
