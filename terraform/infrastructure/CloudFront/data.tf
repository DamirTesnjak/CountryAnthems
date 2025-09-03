data "aws_security_group" "security_group_alb" {
    id = var.security_group_alb_id
}

data "aws_s3_bucket_policy" "frontend_policy" {
    bucket = "${var.name}-frontend"
}

data "aws_s3_bucket" "frontend" {
    bucket = "${var.name}-frontend"
}