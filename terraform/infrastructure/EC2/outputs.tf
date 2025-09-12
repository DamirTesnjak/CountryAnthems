output "capacity_provider_id" {
    value = aws_ecs_capacity_provider.cp.id
}

output "route_table_private_id" {
    value = aws_route_table.private.id
}