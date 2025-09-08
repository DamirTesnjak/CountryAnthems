output security_group_bastion_id {
    value = aws_security_group.bastion_sg.id
}

output aws_instance_bastion_id {
    value = aws_instance.bastion.id
}

output bastion_public_ip {
  value = aws_instance.bastion.public_ip
}

output bastion-private-key {
    value = tls_private_key.bastion.private_key_pem
}