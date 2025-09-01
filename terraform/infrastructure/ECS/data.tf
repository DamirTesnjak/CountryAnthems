data "aws_region" "this" {}

data "aws_ecr_repository" "this" {
  name = var.ecr_repository_name
}

data "aws_ecr_image" "this" {
  repository_name = var.ecr_repository_name
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

data "aws_iam_policy_document" "task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}