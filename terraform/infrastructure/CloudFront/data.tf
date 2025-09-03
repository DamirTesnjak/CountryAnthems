data "aws_security_group" "security_group_alb" {
    vpc_id = var.vpc_id
}

data "aws_s3_bucket_policy" "cloud_front_bucket_access" {
    bucket = "${var.name}-frontend"
}