output "capacity_provider_id" {
    value = aws_ecs_capacity_provider.cp.id
}

output "ecs_agent_subnets" {
    value = local.ecs-agent_selected_subnet_ids
}

output "vpc_endpoints_sg_id" {
    value = aws_security_group.vpc_endpoints.id
}
