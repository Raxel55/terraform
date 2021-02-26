resource "aws_cloudwatch_log_group" "kanda" {
  name = "kanda"

  tags = local.common_tags
}

#resource "aws_cloudwatch_log_stream" "kanda" {
#  name           = "kanda"
#  log_group_name = aws_cloudwatch_log_group.kanda.name
#}
