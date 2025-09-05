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

data "aws_ecs_service" "api" {
  service_name = "${var.name}-service"
  cluster_arn  = var.aws_ecs_cluster_api_arn
}