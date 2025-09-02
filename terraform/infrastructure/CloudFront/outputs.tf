output "cf_id" {
    description = "CloudFront OAC ID"
    value = aws_cloudfront_origin_access_control.s3_oac
}