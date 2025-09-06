resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.name}-bastion"
  public_key = tls_private_key.bastion.public_key_openssh
}

resource "aws_ssm_parameter" "bastion-private-key" {
  name  = "/${var.name}/bastion/private-key"
  type  = "SecureString"
  value = tls_private_key.bastion.private_key_pem
}

resource "aws_security_group" "security_group_EC2" {
  name        = "Security for EC2"
  description = "Security group for EC2"
  vpc_id      = var.vpc_id
}

# allowing connection to EC2
resource "aws_vpc_security_group_ingress_rule" "EC2_allow_public" {
  description       = "Allow connection from outside internet to access EC2"
  cidr_ipv4         = var.bastion_ingress
  from_port         = 22
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.security_group_EC2.id
  to_port           = 22
}

# allowing output from EC2
resource "aws_vpc_security_group_egress_rule" "EC2_allow_public" {
  description       = "Allow from EC2"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.security_group_EC2.id
}

resource "aws_instance" "bastion" {
    ami = "ami-01102c5e8ab69fb75"
    instance_type = "t3a.micro"
    key_name = aws_key_pair.bastion.key_name
    monitoring = true
    associate_public_ip_address = true
    subnet_id = var.public_subnet_bastion

    vpc_security_group_ids = [
      aws_security_group.security_group_EC2.id,
      module.security_group_private.security_group_id,
  ]
}