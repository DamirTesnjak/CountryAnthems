# S3 bucket
resource "aws_s3_bucket" "frontend" {
  bucket        = "${var.name}-frontend"
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

# Allow CloudFront to access S3 bucket
resource "aws_s3_bucket_policy" "lock_to_oac" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.lock_to_oac.json
}

resource "local_file" "config_json" {
  content  = data.template_file.angular_config.rendered
  filename = "/frontend/dist/${var.name}/assets/config.json"
}

resource "aws_s3_object" "angular_assets" {
  for_each = { for file in local.files : file => file }

  bucket = aws_s3_bucket.frontend.bucket
  key    = each.key
  source = "${path.module}/../frontend/dist/${var.name}/${each.key}"
  etag   = filemd5("${path.module}/../frontend/dist/${var.name}/${each.key}")
}
