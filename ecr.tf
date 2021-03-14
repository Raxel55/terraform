resource "aws_ecr_repository" "kanda" {
  name                 = local.name_prefix
  image_tag_mutability = "MUTABLE"
  tags = local.common_tags
  image_scanning_configuration {
    scan_on_push = true
  }
}
