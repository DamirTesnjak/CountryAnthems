resource "aws_cloudwatch_log_group" "this" {
  name              = "country_anthem_cloudwatch_log_group"
  retention_in_days = 30
}

resource "aws_ecs_cluster" "this" {
  name = "country-anthems-api"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_iam_role" "execution" {
  assume_role_policy = data.aws_iam_policy_document.execution_assume_role.json
  name               = "${local.fullname}-execution"
}

resource "aws_iam_role" "task" {
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
  name               = "${var.name}-task"
}

resource "aws_ecs_task_definition" "this" {
  execution_role_arn = aws_iam_role.execution.arn
  family = "${var.name}_api_service"
  task_role_arn = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      image = "${data.aws_ecr_repository.this.repository_url}:${data.aws_ecr_image.this.image_tags[0]}"
      cpu = 0.5
      memory = 1024
      essential = true
      name = "${var.name}_api_service"
      portMappins = [{ containerPort = 5001 }] #the app listens to a port inside container

      secrets = [
        {
          "name": "POSTGRES_USER"
          "valueFrom": data.aws_ssm_parameter.postgres_user.arn
        },
        {
          "name": "POSTGRES_HOST"
          "valueFrom": data.aws_ssm_parameter.postgres_host.arn
        },
        {
          "name": "POSTGRES_DB"
          "valueFrom": data.aws_ssm_parameter.postgres_db.arn
        },
        {
          "name": "POSTGRES_PASSWORD"
          "valueFrom": data.aws_ssm_parameter.postgres_password.arn
        },
        {
          "name": "ORIGIN"
          "valueFrom": [
            "https://${var.bucket_domain_name}"
          ]
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.this.region
          "awslogs-stream-prefix" = "svc"
        }
      }
    }
  ])
}

resource "aws_iam_role" "service" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = "${var.name}_api_service"
}

resource "aws_iam_role_policy_attachment" "service" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = aws_iam_role.service.name
}

resource "aws_lb_target_group" "service" {
  name = "${var.name}-tg"
  deregistration_delay              = 60
  load_balancing_cross_zone_enabled = true
  port                              = var.port
  protocol                          = "HTTP"
  vpc_id                            = var.vpc_id
}

resource "aws_ecs_service" "this" {
  name            = "country-anthems-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  iam_role        = aws_iam_role.service.arn
  depends_on = [aws_iam_role_policy_attachment.service]

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "${var.name}-api-service-spot"
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service.arn
    container_name   = "${var.name}_api_service"
    container_port   = var.port
  }
}
