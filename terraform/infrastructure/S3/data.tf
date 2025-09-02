data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "ecs_s3_policy" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

data "aws_iam_policy_document" "ecs_s3_bucket_access" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    principals {
        identifiers = ["${aws_iam_role.ecs_s3_role_access.arn}"]
        type = "AWS"
    }
    resources = ["${aws_s3_bucket.this.arn}/*"]
    condition {
        test = "StringEquals"
        variable = "aws:SourceVpce"
        values = [ "${aws_vpc_endpoint.s3.id}" ]
    }
  }
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

data "aws_iam_policy_document" "ecs_s3_cloud_front_merged_policy" {
  source_json = data.aws_iam_policy_document.ecs_s3_bucket_access.json
  override_json  = data.aws_iam_policy_document.cloudfront_access.statement
}