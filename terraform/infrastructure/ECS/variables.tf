variable ecr_repository_name {
  type        = string
  description = "ECR repository name"
}

variable vpc_id {
    description = "VPC id value"
    type = string
}

variable name {
    type = string
}

variable port {
    type = number
}

variable bucket_domain_name {
    type = string
}

variable ecs_subnets {
    type = list(string)
}

variable security_group_ecs_id {
    type = string
}
