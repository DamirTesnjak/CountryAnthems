resource "aws_ecr_repository" "this" {
    name = var.ecr_rpository_api_name
    image_tag_mutability = "IMMUTABLE"
    encryption_type = "AES256"
}