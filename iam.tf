data "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"
}

data "aws_iam_role" "ecs-instance-role" {
    name = "ecs-instance-role"
}

data "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "ecs-instance-profile"
}

resource "aws_iam_server_certificate" "kanda" {
  name             = "${local.name_prefix}-https-cert"
  certificate_body = var.https-certs.generate ? tls_self_signed_cert.kanda[0].cert_pem : file(var.https-certs.cert)
  private_key      = var.https-certs.generate ? tls_private_key.kanda-cert[0].private_key_pem : file(var.https-certs.key)
}

resource "tls_private_key" "kanda-cert" {
  count = var.https-certs.generate ? 1 : 0
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "kanda" {
  count = var.https-certs.generate ? 1 : 0
  key_algorithm   = tls_private_key.kanda-cert[0].algorithm
  private_key_pem = tls_private_key.kanda-cert[0].private_key_pem
  validity_period_hours = 720
  early_renewal_hours = 24
  allowed_uses = [
      "key_encipherment",
      "digital_signature",
      "server_auth",
  ]
  dns_names = [aws_lb.kanda.dns_name]
  subject {
      common_name  = aws_lb.kanda.dns_name
      organization = local.name_prefix
  }
}
