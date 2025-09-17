resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.name}-bastion"
  public_key = tls_private_key.bastion.public_key_openssh
}

# genetrate .pem key for SSH connection
resource "local_file" "my-bastion-key" {
  content = tls_private_key.bastion.private_key_pem
  filename = "${var.name}-bastion.pem"
}

# Security group for bastion EC2 instance
resource "aws_security_group" "bastion_sg" {
  name        = "Security for bastion"
  description = "Security group for bastion"
  vpc_id      = var.vpc_id
}

# Allowing connection to bastion EC2 instance
resource "aws_vpc_security_group_ingress_rule" "bastion_sg" {
  description       = "Allow connection from outside internet to access bastion with SSH"
  cidr_ipv4         = var.bastion_ingress
  from_port         = 22
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.bastion_sg.id
  to_port           = 22
}

# Allowing outbound from bastion EC2 instance - remove
resource "aws_vpc_security_group_egress_rule" "bastion_sg" {
  description       = "Allow from bastion"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.bastion_sg.id
}

# New EC2 bastion instance
resource "aws_instance" "bastion" {
    ami = "ami-03aa99ddf5498ceb9"
    instance_type = "t3a.micro"
    key_name = aws_key_pair.bastion.key_name
    monitoring = false
    associate_public_ip_address = true
    subnet_id = var.bastion_public_subnet

    vpc_security_group_ids = [
      aws_security_group.bastion_sg.id,
  ]
}