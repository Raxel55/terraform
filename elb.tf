resource "aws_lb_target_group" "kanda" {
  name     = "${local.name_prefix}-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.kanda.id
  target_type = "ip"
  health_check {
    enabled = true
    path = "/wp-admin/install.php"
  }
#  depends_on = [aws_lb.kanda]
  tags = local.common_tags
}

#resource "aws_lb" "kanda" {
#  name               = "${local.name_prefix}-lb"
#  internal           = false
#  load_balancer_type = "application"
#  subnets            = [aws_subnet.kanda-1.id, aws_subnet.kanda-2.id]
#  security_groups    = [aws_security_group.kanda-alb.id]
#  enable_deletion_protection = true
#  tags = local.common_tags
#}

data "aws_lb" "kanda" {
  name = "kanda"
}

resource "aws_lb_listener" "kanda-1" {
  load_balancer_arn = data.aws_lb.kanda.arn
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
  load_balancer_arn = data.aws_lb.kanda.arn
  port              = "443"
  protocol          = "HTTPS"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kanda.arn
  }
  certificate_arn = "arn:aws:iam::814517281194:server-certificate/kandasoft.com"
}

#resource "aws_lb_listener_certificate" "kanda" {
#  listener_arn    = aws_lb_listener.kanda-2.arn
#  certificate_arn = "arn:aws:acm:us-east-1:814517281194:certificate/aa539f59-04b0-4884-ac80-ff07c5450a24"
#}
