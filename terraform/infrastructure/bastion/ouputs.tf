output security_group_EC2_id {
    value = aws_security_group.security_group_EC2.id
}

output aws_instance_bastion_id {
    value = aws_instance.bastion.id
}