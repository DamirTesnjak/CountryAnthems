data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

data "aws_s3_bucket" "frontend" {
  bucket = "${var.name}-bucket"
}

data "aws_cloudfront_distribution" "cdn" {
  id = var.cf_id
}

data "aws_iam_policy_document" "lock_to_oac" {
  statement {
    sid    = "AllowCloudFrontSigV4Requests"
    effect = "Allow"

    principals {
      type        = "service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${data.aws_s3_bucket.frontend.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [data.aws_cloudfront_distribution.cdn.arn]
    }
  }
}

data "template_file" "angular_config" {
  template = file("${path.module}/config.tpl.json")
  vars     = { api_url = var.ecs_service_url }
}

data "aws_ecs_cluster" "api" {
  cluster_name =  "${var.name}-api"
}

data "aws_ecs_service" "api" {
  service_name = "${var.name}-service"
  cluster_arn  = data.aws_ecs_cluster.api.arn
}