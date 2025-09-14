data "aws_region" "this" {}

data "aws_iam_policy_document" "execution_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
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


data "aws_iam_policy_document" "service_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "execution_policy" {
  statement {
    actions = [
      "ssm:GetParameters",
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "arn:aws:ssm:us-west-2:766020828589:parameter/POSTGRES_USER",
      "arn:aws:ssm:us-west-2:766020828589:parameter/POSTGRES_PASSWORD",
      "arn:aws:ssm:us-west-2:766020828589:parameter/POSTGRES_HOST",
      "arn:aws:ssm:us-west-2:766020828589:parameter/POSTGRES_DB",
      "arn:aws:ssm:us-west-2:766020828589:parameter/POSTGRES_HOST",
      "arn:aws:ssm:us-west-2:766020828589:parameter/ORIGIN",
    ]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }

  statement {
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      aws_cloudwatch_log_group.this.arn,
      "${aws_cloudwatch_log_group.this.arn}:*",
    ]
  }
}

data "aws_security_group" "security_group_ecs" {
  id = var.security_group_ecs_id
}
