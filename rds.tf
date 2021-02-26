resource "aws_db_instance" "kanda" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "kanda"
  name                 = local.db_name
  username             = local.db_user
  password             = local.db_password
  parameter_group_name = "kanda-mysql"
  tags = local.common_tags
}

resource "aws_db_parameter_group" "kanda" {
  name   = "kanda-mysql"
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
