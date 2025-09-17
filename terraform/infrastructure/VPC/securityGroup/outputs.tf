output "database_sg_id" {
  value = aws_security_group.security_group_db.id
}

output "loadBalancer_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "ecs_sg_task_id" {
  value = aws_security_group.ecs_tasks.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_instance.id
}
