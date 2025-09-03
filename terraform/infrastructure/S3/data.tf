data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

data "aws_cloudfront_origin_access_control" "s3_oac" {
  id = var.cf_id
}
data "aws_s3_bucket" "this" {
  bucket = "${var.name}-bucket"
}

data "aws_iam_policy_document" "cloudfront_access" {
  statement {
    sid    = "AllowCloudFront"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_cloudfront_origin_access_control.s3_oac.iam_arn]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${data.aws_s3_bucket.this.arn}/*"
    ]
  }
}