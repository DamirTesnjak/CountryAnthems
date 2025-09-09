resource "aws_ecr_repository" "this" {
  name                 = var.name
  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "null_resource" "push_to_ecr" {
  depends_on = [aws_ecr_repository.this]

  triggers = {
    image_tag = var.image_tag
    always_run = timestamp()
  }

    provisioner "local-exec" {
    # force bash on PATH (Git Bash, WSL, Linux, macOS)
    interpreter = ["bash", "-c"]

    # call the script via an absolute path
    command = <<-EOT
      chmod +x be/api/push_to_ecr.sh \
      "push_to_ecr.sh" \
        ${data.aws_region.this.region} \
        ${aws_ecr_repository.this.repository_url} \
        ${var.name} \
        ${var.image_tag}
    EOT
  }
}