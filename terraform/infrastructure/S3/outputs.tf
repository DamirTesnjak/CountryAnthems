output "bucket_domain_name" {
  description = "Bucket domain name"
  value       = aws_s3_bucket.frontend.bucket_domain_name
}