output "cf_id" {
  description = "CloudFront ID"
  value       = aws_cloudfront_distribution.cdn.id
}

output "ecs_service_url" {
  description = "URL to reach the ECS service via the ALB"
  value       = "http://${aws_lb.api.dns_name}"
}