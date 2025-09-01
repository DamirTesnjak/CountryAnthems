output security_group_db_id {
    value = module.securityGroup.security_group_db.id
}

output vpc_id {
    description = "VPC id value"
    value = aws_vpc.main.id
}

output vpc_name {
    description = "VPC name"
    value = aws_vpc.main.id
}