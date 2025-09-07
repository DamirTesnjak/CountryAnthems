output security_group_bastion_id {
    value = aws_security_group.bastion_sg.id
}

output aws_instance_bastion_id {
    value = aws_instance.bastion.id
}