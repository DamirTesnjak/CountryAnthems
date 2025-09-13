output "capacity_provider_id" {
    value = aws_ecs_capacity_provider.cp.id
}

output "ecs_agent_subnets" {
    value = local.ecs-agent_selected_subnet_ids
}