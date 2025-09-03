output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.this.name
}