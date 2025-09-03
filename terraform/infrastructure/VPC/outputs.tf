output security_group_db_id {
    value = module.securityGroup.security_group_db_id
}

output vpc_id {
    description = "VPC id value"
    value = aws_vpc.main.id
}

output vpc_name {
    description = "VPC name"
    value = aws_vpc.main.id
}

output alb_subnets {
    description = "ALB subnets"
    value = [
        aws_subnet.private_1_us_west_2a.id,
        aws_subnet.private_3_us_west_2b.id,
        aws_subnet.private_5_us_west_2c.id
    ]
}

output db_subnets {
    description = "DB subnets"
    value = [
        aws_subnet.private_2_us_west_2a.id,
        aws_subnet.private_4_us_west_2b.id,
        aws_subnet.private_6_us_west_2c.id
    ]
}