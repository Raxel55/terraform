resource "aws_ecs_cluster" "kanda" {
  name = "${local.name_prefix}-cluster"
  capacity_providers = ["${local.name_prefix}-capacity-provider"]
  depends_on = [aws_ecs_capacity_provider.kanda]
  default_capacity_provider_strategy {
    capacity_provider = "${local.name_prefix}-capacity-provider"
    weight = "1"
  }
  tags = local.common_tags
}

resource "aws_launch_configuration" "kanda" {
    name_prefix                 = local.name_prefix
    image_id                    = "ami-09a3cad575b7eabaa"
    instance_type               = "t2.medium"
    iam_instance_profile        = data.aws_iam_instance_profile.ecs-instance-profile.arn
    root_block_device {
      volume_type = "standard"
      volume_size = 100
      delete_on_termination = true
    }
    lifecycle {
      create_before_destroy = true
    }
    security_groups             = [aws_security_group.kanda-ec2.id]
    associate_public_ip_address = "true"
    key_name                    = aws_key_pair.kanda.key_name
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=${local.name_prefix}-cluster >> /etc/ecs/ecs.config
                                  EOF
}

resource "aws_key_pair" "kanda" {
  key_name_prefix   = local.name_prefix
  public_key = var.ssh-key-pair.generate ? tls_private_key.kanda-ssh[0].public_key_openssh : file(var.ssh-key-pair.public_key)
  tags = local.common_tags
}

resource "tls_private_key" "kanda-ssh" {
  count = var.ssh-key-pair.generate ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_autoscaling_group" "kanda" {
  name               = "${local.name_prefix}-asg"
  vpc_zone_identifier = [data.aws_subnet.kanda-1.id, data.aws_subnet.kanda-2.id]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 0
  launch_configuration = aws_launch_configuration.kanda.name
  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key   
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

data "aws_ecr_repository" "kanda" {
  name = "kanda"
}

resource "aws_ecs_capacity_provider" "kanda" {
  name = "${local.name_prefix}-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.kanda.arn
#    managed_termination_protection = "ENABLED"
    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
  tags = local.common_tags
}

resource "aws_ecs_task_definition" "kanda" {
  family                = local.name_prefix
  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "${local.name_prefix}",
    "image": "${data.aws_ecr_repository.kanda.repository_url}:develop",
    "memoryReservation": 1024,
    "essential": true,
    "secrets": [
        {
          "name": "WORDPRESS_DB_NAME",
          "valueFrom": "${aws_ssm_parameter.db-name.arn}"
        },
        {
          "name": "WORDPRESS_DB_USER",
          "valueFrom": "${aws_ssm_parameter.db-user.arn}"
        },
        {
          "name": "WORDPRESS_DB_PASSWORD",
          "valueFrom": "${aws_ssm_parameter.db-password.arn}"
        },
        {
          "name": "WORDPRESS_DB_HOST",
          "valueFrom": "${aws_ssm_parameter.db-host.arn}"
        }
      ],
    "portMappings": [
      {
        "containerPort": 80
      }
    ],
    "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "${local.name_prefix}-log-group",
                    "awslogs-region": "${var.aws_region}",
                    "awslogs-stream-prefix": "${local.name_prefix}"
                }
            }
  }
]
TASK_DEFINITION
  task_role_arn = data.aws_iam_role.ecs_execution_role.arn
  execution_role_arn = data.aws_iam_role.ecs_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["EC2"]
  tags = local.common_tags
}

resource "aws_ecs_service" "kanda" {
  name            = "${local.name_prefix}-ecs-service"
  cluster         = aws_ecs_cluster.kanda.id
  task_definition = aws_ecs_task_definition.kanda.arn
  desired_count   = 1
  network_configuration {
    subnets = [data.aws_subnet.kanda-1.id, data.aws_subnet.kanda-2.id]
    security_groups = [aws_security_group.kanda-ec2.id]
    assign_public_ip = false
  }
  capacity_provider_strategy {
    capacity_provider = "${local.name_prefix}-capacity-provider"
    base = 0
    weight = 1
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.kanda.arn
    container_name   = local.name_prefix
    container_port   = 80
  }
  tags = local.common_tags
}
