resource "aws_ecr_repository" "this" {
    name = var.ecr_repository_api_name
    image_tag_mutability = "IMMUTABLE"
    encryption_configuration {
        encryption_type = "AES256"
    }
}