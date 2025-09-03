output "security_group_db_id" {
  value = aws_security_group.security_group_db.id
}

output "security_group_ecs_id" {
  value = aws_security_group.security_group_ecs.id
}

output "security_group_alb_id" {
  value = aws_security_group.security_group_alb.id
}