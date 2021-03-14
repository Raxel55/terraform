resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = local.common_tags
}


resource "aws_iam_role_policy" "ecr_read_only" {
  name = "ecr_read_only"
  role = aws_iam_role.ecs_execution_role.id
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:GetLifecyclePolicy",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:ListTagsForResource",
        "ecr:DescribeImageScanFindings",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs-instance-role" {
    name                = "ecs-instance-role"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.ecs-instance-policy.json
}

data "aws_iam_policy_document" "ecs-instance-policy" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
    role       = aws_iam_role.ecs-instance-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "ecs-instance-profile"
    path = "/"
    role = aws_iam_role.ecs-instance-role.id
    provisioner "local-exec" {
      command = "sleep 10"
    }
}

resource "aws_iam_server_certificate" "kanda" {
  name             = "${local.name_prefix}-https-cert"
  certificate_body = var.https-certs.generate ? tls_self_signed_cert.kanda[0].cert_pem : file(var.https-certs.cert)
  private_key      = var.https-certs.generate ? tls_private_key.kanda-cert[0].private_key_pem : file(var.https-certs.key)
}

resource "tls_private_key" "kanda-cert" {
  count = var.https-certs.generate ? 1 : 0
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "kanda" {
  count = var.https-certs.generate ? 1 : 0
  key_algorithm   = tls_private_key.kanda-cert[0].algorithm
  private_key_pem = tls_private_key.kanda-cert[0].private_key_pem
  validity_period_hours = 12
  early_renewal_hours = 3
  allowed_uses = [
      "key_encipherment",
      "digital_signature",
      "server_auth",
  ]
  dns_names = [aws_lb.kanda.dns_name]
  subject {
      common_name  = "aws_lb.kanda.dns_name"
      organization = local.name_prefix
  }
}
