# S3 bucket
resource "aws_s3_bucket" "this" {
  bucket = "${var.name}-bucket"
  force_destroy = true
}

# Object ownership in bucket
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


# Block all public access to bucket
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [aws_s3_bucket_ownership_controls.this]

  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

# Bucket versioning, good for restoring old versions
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
}

# VPC Endpoint for S3 (Private Access)
resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.this.id
    service_name = data.aws_vpc_endpoint_service.s3.service_name
    vpc_endpoint_type = "Gateway"

    route_table_ids = [
        aws_route_table.this.id
    ]
}

resource "aws_iam_role" "esc_s3_role_access" {
  name = "esc_s3_role_access"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy" "ecs_s3_policy" {
  role = aws_iam_role.ecs_s3_role_access.id
  policy = data.aws_iam_policy_document.ecs_s3_policy.json
}


resource "aws_s3_bucket_policy" "ecs_s3_bucket_access" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.ecs_s3_cloud_front_merged_policy.json
}
