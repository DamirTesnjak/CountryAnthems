output database_user {
    value = aws_ssm_parameter.postgres_user.value
}

output db_name {
    value = aws_ssm_parameter.postgres_user.value
}


output aws_ecs_cluster_api_arn {
    value = aws_ecs_cluster.cluster.arn
}

output loadBalancer_tg_service_arn {
    value = aws_lb_target_group.service.arn
}