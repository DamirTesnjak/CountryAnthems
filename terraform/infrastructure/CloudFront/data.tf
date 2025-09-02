data "aws_security_group" "security_group_alb" {
    vpc_id = var.vpc_id
}