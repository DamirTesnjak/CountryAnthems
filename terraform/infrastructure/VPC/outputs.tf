output "database_sg_id" {
  value = module.securityGroup.database_sg_id
}

output "vpc_id" {
  description = "VPC id value"
  value       = aws_vpc.main.id
}

output "vpc_name" {
  description = "VPC name"
  value       = aws_vpc.main.id
}

output "loadBalancer_subnets" {
  description = "ALB subnets"
  value = [
    aws_subnet.public_1_us_west_2a.id,
    aws_subnet.public_3_us_west_2b.id,
    aws_subnet.public_5_us_west_2c.id
  ]
}

output "database_subnets" {
  description = "DB subnets"
  value = [
    aws_subnet.private_2_us_west_2a.id,
    aws_subnet.private_4_us_west_2b.id,
    aws_subnet.private_6_us_west_2c.id
  ]
}

output "loadBalancer_sg_id" {
  value = module.securityGroup.loadBalancer_sg_id
}

output "bastion_public_subnet" {
  value = aws_subnet.public_bastion.id
}

output "ecs_sg_task_id" {
  value = module.securityGroup.ecs_sg_task_id
}

output "ecs_sg_id" {
  value = module.securityGroup.ecs_sg_id
}