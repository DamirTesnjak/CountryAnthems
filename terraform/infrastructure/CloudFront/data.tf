data "aws_security_group" "security_group_alb" {
  id = var.security_group_alb_id
}