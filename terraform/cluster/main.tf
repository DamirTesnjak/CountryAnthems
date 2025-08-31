# ECR - settings

resource "aws_ecr_repository" "country_anthems_api_repository" {
    name = var.ecr_repository_name_api
    image_tag_mutability = "IMMUTABLE"
    encryption_type = "AES256"
}

# API settings
resource "aws_ecs_cluster" "api" {
  name = "country-anthems-api"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_subnet" "API-private-us-west-2c" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.48.0/20"

  tags = {
    Name = "private-us-west-2a"
  }
}

resource "aws_security_group" "security_group_api" {
  name        = "Security_API"
  description = "Security group for API"
  vpc_id      = aws_vpc.country-anthems-vpc.id

  tags = {
    Name = "allow_tls"
  }
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}
data "aws_ecr_repository" "country_anthems_api_repository" {
  name = var.ecr_repository_name_api
}

data "aws_ecr_image" "country_anthem_api_image" {
  repository_name = var.ecr_repository_name_api
  image_tag       = "latest"
}

data "aws_ssm_parameter" "postgres_user" {
  name = "postgres_user"
}

data "aws_ssm_parameter" "postgres_host" {
  name = "postgres_host"
}

data "aws_ssm_parameter" "postgres_db" {
  name = "postgres_db"
}

data "aws_ssm_parameter" "postgres_password" {
  name = "postgres_password"
}

resource "aws_cloudwatch_log_group" "country_anthem_cloudwatch_log_group" {
  name              = "country_anthem_cloudwatch_log_group"
  retention_in_days = 10
}

resource "aws_esc_task_definition" "country_anthem_api_service" {
  family = "country_anthem_api_service"
  container_definitions = jsonencode([
    {
      image = "${data.aws_ecr_repository.country_anthems_api_repository.repository_url}:${data.aws_ecr_image.country_anthem_api_image.image_tags[0]}"
      cpu = 0.5
      memory = 1024
      essential = true
      name = "country_anthem_api_service"
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
            "https://${aws_s3_bucket.country_anthems_s3_bucket.bucket_domain_name}"
          ]
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.country_anthem_cloudwatch_log_group.name
          "awslogs-region"        = data.aws_region.this.name
          "awslogs-stream-prefix" = "svc"
        }
      }
    }
  ])
}


data "aws_iam_policy_document" "task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "country_anthem_api_service" {
  assume_role_policy = data.aws_iam_policy_document.service_assume_role.json
  name               = "country_anthem_api-service"
}

resource "aws_iam_role_policy_attachment" "country_anthem_api_service" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = aws_iam_role.country_anthem_api_service.name
}

resource "aws_lb_target_group" "country-anthems-service" {
  deregistration_delay              = 60
  load_balancing_cross_zone_enabled = true
  port                              = 5001
  protocol                          = "HTTP"
  vpc_id                            = aws_vpc.country-anthems-vpc.id
}

resource "aws_ecs_service" "country-anthems-api-service" {
  name            = "country-anthems-service"
  cluster         = aws_ecs_cluster.api.id
  task_definition = aws_ecs_task_definition.country_anthem_api_service.arn
  desired_count   = 1
  iam_role        = aws_iam_role.country_anthem_api_service.arn
  depends_on = [aws_iam_role_policy_attachment.country_anthem_api_service]

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "country-anthems-api-service-spot"
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.country-anthems-service.arn
    container_name   = "country_anthem_api_service"
    container_port   = 5001
  }
}

# S3 - bucket configs

resource "aws_s3_bucket" "country_anthems_s3_bucket" {
    bucket = var.country_anthems_S3_bucket_name
    force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.country_anthems_s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.country_anthems_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.country_anthems_s3_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.country_anthems_s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

# RDS configurations
resource "random_string" "password" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "password" {
  name  = "/${var.name}/database/password"
  type  = "SecureString"
  value = random_string.password.result
}

resource "aws_db_subnet_group" "country_anthems_database_subnets" {
  name       = "education"
  subnet_ids = [
    aws_subnet.private-database-us-west-2a.id,
    aws_subnet.private-database-us-west-2b.id
    ]

  tags = {
    Name = "country-Anthems-database"
  }
}

resource "aws_security_group" "security_group_db" {
  name        = "Security_DB"
  description = "Security group for database"
  vpc_id      = aws_vpc.country-anthems-vpc.id

  tags = {
    Name = "allow_tls"
  }
}

# allowing connection to DB
resource "aws_vpc_security_group_ingress_rule" "db_allow_private" {
  description                  = "Allow private subnet to access db"
  from_port                    = 5432
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group_db.security_group_db.id
  to_port                      = 5432
}

# allowing output from DB
resource "aws_vpc_security_group_egress_rule" "db_allow_private" {
  description  = "Allow private subnet from db"
  from_port   = 5432
  ip_protocol = "tcp"
  security_group_id = aws_security_group_db.security_group_db.id
  to_port     = 5432
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 1
  create_db_option_group              = false
  create_db_parameter_group           = false
  create_db_subnet_group              = false
  create_monitoring_role              = false
  db_name              = "country-anthems-postgres-database"
  engine               = "postgres"
  engine_version       = "17.6"
  iam_database_authentication_enabled = false
  instance_class       = "db.t4g.micro"
  username             = "postgres"
  password             = random_string.password.result
  parameter_group_name = "default.postgres17"
  db_subnet_group_name  = aws_db_subnet_group.country_anthems_database_subnets
  publicly_accessible = false
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.security_group_db.id]
}

resource "null_resource" "enable_postgis" {
  depends_on = [aws_db_instance.postgres]

  provisioner "local-exec" {
    command = <<EOT
PGPASSWORD=${random_string.password.result} psql \
  --host=${aws_db_instance.postgres.address} \
  --port=5432 \
  --username=${aws_db_instance.postgres.username} \
  --dbname=${aws_db_instance.postgres.db_name} \
  -c "CREATE EXTENSION IF NOT EXISTS postgis;"
EOT
  }
}

# VPC configurations

data "aws_region" "current" {}

# get bucket ARN
data "aws_s3_bucket" "country_anthems_s3_bucket" {
    arn = aws_s3_bucket.country_anthems_s3_bucket.arn
}

resource "aws_vpc" "country-anthems-vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    avability_zone = ["us-west-2a", "us-west-2b"]

    tags = {
        Name = "country-anthems-vpc"
    }
}

resource "aws_subnet" "private-database-us-west-2a" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.16.0/20"

  tags = {
    Name = "private-database-us-west-2a"
  }
}

resource "aws_subnet" "private-database-us-west-2b" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.32.0/20"

  tags = {
    Name = "private-database-us-west-2b"
  }
}


resource "aws_subnet" "private-us-west-2c" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.48.0/20"

  tags = {
    Name = "private-us-west-2a"
  }
}

resource "aws_subnet" "private-us-west-2d" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.64.0/20"

  tags = {
    Name = "private-us-west-2b"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.country_anthems_vpc.id
}

# connecting S3 bucket to VPC
resource "aws_vpc_endpoint" "country_anthems_s3_bucket" {
    vpc_id = aws_vpc.country_anthems_vpc.id
    service_network_arn = data.aws_s3_bucket.country_anthems_s3_bucket.arn
    vpc_endpoint_type = "Gateway"

    route_table_ids = [
        aws_route_table.private.id
    ]
}
