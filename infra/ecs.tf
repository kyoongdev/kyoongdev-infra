
data "template_file" "service" {
  template = file(var.template_path)
  vars = {
    region             = var.region
    aws_ecr_repository = var.repository_url
    tag                = "latest"
    container_port     = var.container_port
    host_port          = var.host_port
    app_name           = var.app_name
  }
}

resource "aws_ecs_task_definition" "default" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.service.rendered

  tags = {
    Environment = "staging"
    Application = var.app_name
  }
}

resource "aws_ecs_cluster" "default" {
  name = "${var.app_name}-cluster"
}


resource "aws_ecs_service" "staging" {
  name                 = "${var.app_name}-service-${var.env}"
  cluster              = aws_ecs_cluster.default.id
  task_definition      = aws_ecs_task_definition.default.arn
  desired_count        = 1
  force_new_deployment = true
  launch_type          = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_task.id]
    subnets          = aws_subnet.private_subnet[*].id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.alb_tg.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_alb_listener.http,
    aws_iam_role_policy_attachment.ecs_task_execution_role,
  ]

  tags = {
    Application = var.app_name
  }
}
