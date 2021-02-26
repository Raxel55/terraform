resource "aws_ecr_repository" "kanda" {
  name                 = "kanda"
  image_tag_mutability = "MUTABLE"
  tags = {
    managed_by = "terraform"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
}
