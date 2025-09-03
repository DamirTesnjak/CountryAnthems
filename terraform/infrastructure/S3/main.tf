# S3 bucket
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.name}-frontend"
  force_destroy = true
}

# Object ownership in bucket
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.frontend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Block all public access to bucket
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "alc" {
  depends_on = [aws_s3_bucket_ownership_controls.this]

  bucket = aws_s3_bucket.frontend.id
  acl    = "private"
}

# Bucket versioning, good for restoring old versions
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id
}

# VPC Endpoint for S3 (Private Access)
resource "aws_vpc_endpoint" "s3" {
    vpc_id = var.vpc_id
    service_name = data.aws_vpc_endpoint_service.s3.service_name
    vpc_endpoint_type = "Gateway"

    route_table_ids = [
        aws_route_table.this.id
    ]
}

# Allow CloudFront to access S3 bucket
resource "aws_s3_bucket_policy" "cloud_front_bucket_access" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.cloudfront_access.json
}
