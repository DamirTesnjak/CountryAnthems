output bastion_sg_id {
    description = "EC2 Bastion security group ID"
    value = aws_security_group.bastion_sg.id
}

output bastion_id {
    description = "EC2 Bastion ID"
    value = aws_instance.bastion.id
}

output bastion_public_ip {
  description = "EC2 Bastion public IP"
  value = aws_instance.bastion.public_ip
}

output bastion_private_key {
    description = "Key for SSH connection"
    value = tls_private_key.bastion_private_key.private_key_pem
}