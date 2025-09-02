output "bucket_domain_name" {
    description = "Bucket domain name"
    value = aws_s3_bucket.this.bucket_domain_name
}