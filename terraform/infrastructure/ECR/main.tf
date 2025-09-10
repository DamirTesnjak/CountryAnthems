resource "aws_ecr_repository" "this" {
  name                 = var.name
  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "null_resource" "push_to_ecr" {
  depends_on = [aws_ecr_repository.this]

  triggers = {
    image_tag  = var.image_tag
    always_run = timestamp()
  }

  provisioner "local-exec" {
    working_dir = "${path.module}"
    interpreter = ["bash", "-c"]

    command = <<-EOT
    export REGION="${data.aws_region.this.region}"
    export REPO_URL="${aws_ecr_repository.this.repository_url}"
    export NAME="${var.name}"
    export IMAGE_TAG="${var.image_tag}"
    cd ../../../be/api
    chmod +x ./push_to_ecr.sh
    ./push_to_ecr.sh
    EOT
  }
}