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
      "arn:aws:ssm:${data.aws_region.this.region}:${var.aws_account_id}:parameter/POSTGRES_USER",
      "arn:aws:ssm:${data.aws_region.this.region}:${var.aws_account_id}:parameter/POSTGRES_PASSWORD",
      "arn:aws:ssm:${data.aws_region.this.region}:${var.aws_account_id}:parameter/POSTGRES_HOST",
      "arn:aws:ssm:${data.aws_region.this.region}:${var.aws_account_id}:parameter/POSTGRES_DB",
      "arn:aws:ssm:${data.aws_region.this.region}:${var.aws_account_id}:parameter/POSTGRES_HOST",
      "arn:aws:ssm:${data.aws_region.this.region}:${var.aws_account_id}:parameter/ORIGIN",
    ]
  }

  statement {
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [
      aws_cloudwatch_log_group.this.arn,
      "${aws_cloudwatch_log_group.this.arn}:*",
    ]
  }
}