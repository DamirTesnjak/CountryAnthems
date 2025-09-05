output postgres_user {
    value = aws_ssm_parameter.postgres_user.value
}

output aws_ecs_cluster_api_arn {
    value = aws_ecs_cluster.api.arn
}