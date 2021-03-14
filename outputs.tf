output "aws_ecr_repository_url" {
  value = aws_ecr_repository.kanda.repository_url
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "aws_db_instance_address" {
  value = aws_db_instance.kanda.address
}
