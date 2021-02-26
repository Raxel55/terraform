resource "aws_ecs_cluster" "kanda" {
  name = "kanda"
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = "1"
  }
  tags = local.common_tags
}

resource "aws_ecs_task_definition" "kanda" {
  family                = "kanda"
  container_definitions = file("service.json")
  task_role_arn = aws_iam_role.ecs_execution_role.arn
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 2048
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
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.kanda-1.arn
    container_name   = "kanda"
    container_port   = 80
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.kanda-2.arn
    container_name   = "kanda"
    container_port   = 8080
  }

  tags = local.common_tags

}
