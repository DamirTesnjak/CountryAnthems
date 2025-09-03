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