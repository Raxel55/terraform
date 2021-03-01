resource "aws_ecs_cluster" "kanda" {
  name = "kanda"
  capacity_providers = ["kanda"]
  depends_on = [aws_ecs_capacity_provider.kanda]
  default_capacity_provider_strategy {
    capacity_provider = "kanda"
    weight = "1"
  }
  tags = local.common_tags
}

resource "aws_launch_configuration" "kanda" {
    name_prefix                 = "kanda"
    image_id                    = "ami-0ecd34837cf9fa094"
    instance_type               = "t2.medium"
    iam_instance_profile        = aws_iam_instance_profile.ecs-instance-profile.id

    root_block_device {
      volume_type = "standard"
      volume_size = 100
      delete_on_termination = true
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = [aws_default_security_group.kanda.id]
    associate_public_ip_address = "true"
    key_name                    = aws_key_pair.kanda.key_name
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=kanda >> /etc/ecs/ecs.config
                                  EOF
}

resource "aws_key_pair" "kanda" {
  key_name_prefix   = "kanda"
  public_key = file("ssh-rsa.public.key")
}

#resource "aws_launch_template" "kanda" {
#  name_prefix   = "kanda"
#  image_id      = "ami-0ecd34837cf9fa094"
#  instance_type = "t3.medium"
#}

resource "aws_autoscaling_group" "kanda" {
  name               = "kanda"
#  availability_zones = ["us-east-1a", "us-east-1b"]
  vpc_zone_identifier = [aws_subnet.kanda-1.id, aws_subnet.kanda-2.id]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 0
  launch_configuration        = aws_launch_configuration.kanda.name
#  health_check_type           = "ELB"

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

}

resource "aws_ecs_capacity_provider" "kanda" {
  name = "kanda"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.kanda.arn
#    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "DISABLED"
      target_capacity           = 1
    }
  }
}

resource "aws_ecs_task_definition" "kanda" {
  family                = "kanda"
  container_definitions = file("service.json")
  task_role_arn = aws_iam_role.ecs_execution_role.arn
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu = 128
  memory = 1024
  tags = local.common_tags
}

resource "aws_ecs_service" "kanda" {
  name            = "kanda"
  cluster         = aws_ecs_cluster.kanda.id
  task_definition = aws_ecs_task_definition.kanda.arn
  desired_count   = 1

  network_configuration {
    subnets = [aws_subnet.kanda-1.id, aws_subnet.kanda-2.id]
    security_groups = [aws_vpc.kanda.default_security_group_id]
    assign_public_ip = false
  }

  capacity_provider_strategy {
    capacity_provider = "kanda"
    base = 0
    weight = 1
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.kanda-1.arn
    container_name   = "kanda"
    container_port   = 80
  }

#  load_balancer {
#    target_group_arn = aws_lb_target_group.kanda-2.arn
#    container_name   = "kanda"
#    container_port   = 443
#  }

  tags = local.common_tags

}
