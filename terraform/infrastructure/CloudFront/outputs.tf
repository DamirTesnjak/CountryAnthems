output "cloudFront_id" {
  description = "CloudFront ID"
  value       = aws_cloudfront_distribution.cloud_front_distribution.id
}

output "ecs_service_url" {
  description = "URL to reach the ECS service via the ALB"
  value       = "http://${aws_lb.load_balancer_api.dns_name}"
}

output "public_route_table_id" {
  description = "Public route table"
  value = aws_route_table.public_route_table.id
}

output "cloudfront_domain" {
  description = "CloudFront domain name"
  value = aws_cloudfront_distribution.cloud_front_distribution.domain_name
}
