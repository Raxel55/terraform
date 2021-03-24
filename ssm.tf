resource "aws_ssm_parameter" "db-name" {
  name        = "/${local.name_prefix}/database/name"
  description = "The database name"
  type        = "String"
  overwrite   = true
  value       = var.database.name
  tags = local.common_tags
}

resource "aws_ssm_parameter" "db-user" {
  name        = "/${local.name_prefix}/database/user"
  description = "The database user"
  type        = "String"
  overwrite   = true
  value       = var.database.user
  tags = local.common_tags
}

resource "aws_ssm_parameter" "db-password" {
  name        = "/${local.name_prefix}/database/password"
  description = "The database password"
  type        = "SecureString"
  overwrite   = true
  value       = var.database.password
  tags = local.common_tags
}

resource "aws_ssm_parameter" "db-host" {
  name        = "/${local.name_prefix}/database/host"
  description = "The database name"
  type        = "String"
  overwrite   = true
  value       = data.aws_db_instance.kanda.address
  tags = local.common_tags
}
