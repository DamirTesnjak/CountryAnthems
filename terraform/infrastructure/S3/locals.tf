locals {
  files = fileset("${path.module}/../frontend/dist/${var.name}", "**")
}
