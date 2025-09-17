resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.name}_cloudwatch_log_group"
  retention_in_days = 30
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  depends_on = [
    var.capacity_provider_id
  ]
}

resource "aws_iam_policy" "execution_policy" {
  name   = "${var.name}-execution"
  policy = data.aws_iam_policy_document.execution_policy.json
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.execution.name
  policy_arn = aws_iam_policy.execution_policy.arn
}

resource "aws_iam_role" "execution" {
  assume_role_policy = data.aws_iam_policy_document.execution_assume_role.json
  name               = "${var.name}-execution"
}

resource "aws_iam_role" "task" {
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
  name               = "${var.name}-task"
}

resource "aws_ssm_parameter" "postgres_user" {
  name  = "POSTGRES_USER"
  type  = "SecureString"
  value = "database_user"
}

resource "aws_ssm_parameter" "postgres_host" {
  name  = "POSTGRES_HOST"
  type  = "SecureString"
  value = var.database_host
}

resource "aws_ssm_parameter" "postgres_db" {
  name  = "POSTGRES_DB"
  type  = "SecureString"
  value = var.database_name
}

resource "aws_ssm_parameter" "postgres_password" {
  name  = "POSTGRES_PASSWORD"
  type  = "SecureString"
  value = var.database_password
}

resource "aws_ssm_parameter" "origin" {
  name  = "ORIGIN"
  type  = "SecureString"
  value = var.cloudfront_domain
}

resource "aws_ecs_task_definition" "api_task" {
  execution_role_arn = aws_iam_role.execution.arn
  family             = "${var.name}-task"
  task_role_arn      = aws_iam_role.task.arn
  network_mode = "awsvpc"
  requires_compatibilities = ["EC2"]


  container_definitions = <<TASK_DEFINITION
  [
    {
      "image": "${var.image_registry}/${var.image_repository}:${var.image_tag}",
      "cpu": 256,
      "memory": 256,
      "essential": true,
      "name": "${var.name}_api_service",
      "portMappings": [
        { 
          "containerPort": ${var.port} 
        }
      ],
      "environment": [
        {
          "name": "API_PORT",
          "value": "${var.port}"
        },
        {
          "name": "API_HOST",
          "value": "0.0.0.0"
        }
      ],
      "secrets": [
        {
          "name": "${aws_ssm_parameter.postgres_user.name}",
          "valueFrom": "${aws_ssm_parameter.postgres_user.arn}"
        },
        {
          "name": "${aws_ssm_parameter.postgres_host.name}",
          "valueFrom": "${aws_ssm_parameter.postgres_host.arn}"
        },
        {
          "name": "${aws_ssm_parameter.postgres_db.name}",
          "valueFrom": "${aws_ssm_parameter.postgres_db.arn}"
        },
        {
          "name": "${aws_ssm_parameter.postgres_password.name}",
          "valueFrom": "${aws_ssm_parameter.postgres_password.arn}"
        },
        {
          "name": "${aws_ssm_parameter.origin.name}",
          "valueFrom": "${aws_ssm_parameter.origin.arn}"
        }
      ],

      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.this.name}",
          "awslogs-region": "${data.aws_region.this.region}",
          "awslogs-stream-prefix": "api"
        }
      }
    }
  ]
  TASK_DEFINITION
}

resource "aws_iam_role" "service" {
  assume_role_policy = data.aws_iam_policy_document.service_assume_role.json
  name               = "${var.name}-service"
}

resource "aws_iam_role_policy_attachment" "execution_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.execution.name
}


resource "aws_iam_role_policy_attachment" "service" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = aws_iam_role.service.name
}

resource "aws_lb_target_group" "service" {
  name                              = "${var.name}-tg"
  deregistration_delay              = 60
  load_balancing_cross_zone_enabled = true
  port                              = var.port
  protocol                          = "HTTP"
  vpc_id                            = var.vpc_id
  target_type = "ip"
}

resource "aws_ecs_service" "api" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.api_task.arn
  desired_count   = 1
  launch_type     = "EC2" 
  depends_on      = [aws_iam_role_policy_attachment.service]

  network_configuration {
    subnets          = var.ecs_agent_subnets_id
    security_groups  = [var.ecs_sg_task_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = "${var.name}_api_service"
    container_port   = var.port
  }
}
