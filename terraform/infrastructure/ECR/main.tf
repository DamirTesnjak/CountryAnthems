resource "aws_ecr_repository" "this" {
  name                 = var.ecr_repository_api_name
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_registry_image" "app_image" {
  name = "${aws_ecr_repository.this.repository_url}:${var.image_tag}"

  build {
    context    = "${path.module}/../../../be/api"
    dockerfile = "${path.module}/../../../be/api/Dockerfile"
  }

  registry_auth {
    address  = aws_ecr_repository.app.repository_url
    username = data.aws_ecr_authorization_token.auth.user_name
    password = data.aws_ecr_authorization_token.auth.password
  }
}

/*resource "null_resource" "push_to_ecr" {
  depends_on = [aws_ecr_repository.app]

  triggers = {
    image_tag = var.image_tag
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws ecr get-login-password --region ${var.aws_region} \
      | docker login --username AWS --password-stdin ${aws_ecr_repository.this.repository_url}

      docker build \
        -t ${aws_ecr_repository.app.repository_url}:${var.image_tag} \
        ${path.module}/../../../be/api

      docker push ${aws_ecr_repository.app.repository_url}:${var.image_tag}
    EOT
  }
}*/