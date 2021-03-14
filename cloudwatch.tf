resource "aws_cloudwatch_log_group" "kanda" {
  name = "${local.name_prefix}-log-group"
  tags = local.common_tags
}
