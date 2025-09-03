output "cf_id" {
    description = "CloudFront ID"
    value = aws_cloudfront_distribution.cdn.id
}