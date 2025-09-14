data "aws_region" "this" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_route_tables" "private" {
  vpc_id = var.vpc_id
  
  filter {
    name   = "association.subnet-id"
    values = local.ecs-agent_selected_subnet_ids
  }
}
