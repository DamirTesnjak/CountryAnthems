output db_user {
    value = aws_ssm_parameter.postgres_user.value
}

output db_name {
    value = aws_ssm_parameter.postgres_user.value
}


output aws_ecs_cluster_api_arn {
    value = aws_ecs_cluster.api.arn
}

output aws_lb_target_group_service_arn {
    value = aws_lb_target_group.service.arn
}