resource "aws_lb_target_group" "kanda" {
  name     = "${local.name_prefix}-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.kanda.id
  target_type = "ip"
  health_check {
    enabled = true
    path = "/wp-admin/install.php"
  }
  depends_on = [aws_lb.kanda]
  tags = local.common_tags
}

resource "aws_lb" "kanda" {
  name               = "${local.name_prefix}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.kanda-1.id, aws_subnet.kanda-2.id]
  enable_deletion_protection = true
  tags = local.common_tags
}

resource "aws_lb_listener" "kanda-1" {
  load_balancer_arn = aws_lb.kanda.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "kanda-2" {
  load_balancer_arn = aws_lb.kanda.arn
  port              = "443"
  protocol          = "HTTPS"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kanda.arn
  }
  certificate_arn = aws_iam_server_certificate.kanda.arn
}
