resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "null_resource" "push_to_ecr" {
  depends_on = [aws_ecr_repository.this]

  triggers = {
    image_tag = var.image_tag
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../../../be/api"
    command = <<-EOT
      aws ecr get-login-password --region ${data.aws_region.this} \
      | docker login --username AWS --password-stdin ${aws_ecr_repository.this.repository_url}

      docker build -t ${var.name}-api:${var.image_tag} .
      
      docker tag ${var.name}-api:${var.image_tag} ${aws_ecr_repository.this.repository_url}/${var.name}-api:${var.image_tag}

      docker push ${var.name}-api:${var.image_tag}
    EOT
  }
}