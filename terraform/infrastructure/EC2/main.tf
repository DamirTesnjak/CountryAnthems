resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "${var.name}-cluster"
  public_key = tls_private_key.ec2.public_key_openssh
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = var.name
}

resource "aws_iam_role_policy_attachment" "service_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.this.name
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-ecs-instance-profile"
  role = aws_iam_role.this.name
}

resource "aws_security_group" "ec2_sg" {
  name        = "Security for ec2"
  description = "Security group for ec2"
  vpc_id      = var.vpc_id
}

# Security group for VPC Interface Endpoints
resource "aws_security_group" "vpce" {
  name        = "${var.name}-vpce-sg"
  description = "Allow ECS/ECR/SSM traffic from ECS instances to VPC endpoints"
  vpc_id      = var.vpc_id
}

# Allow inbound HTTPS from ECS instance SG to the endpoints
resource "aws_vpc_security_group_ingress_rule" "vpce_from_ecs" {
  security_group_id            = aws_security_group.vpce.id
  referenced_security_group_id = aws_security_group.ec2_sg.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

# Allow all outbound from the endpoints (usually default)
resource "aws_vpc_security_group_egress_rule" "vpce_all_out" {
  security_group_id = aws_security_group.vpce.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# allowing output from EC2
resource "aws_vpc_security_group_egress_rule" "ec2_sg" {
  description       = "Allow from ec2"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.ec2_sg.id
}

# ECS control plane
resource "aws_vpc_endpoint" "ecs-control-plane" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.this.region}.ecs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.ecs_control
  security_group_ids = [aws_security_group.vpce.id]
}

# ECR API
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.this.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.ecr_api
  security_group_ids = [aws_security_group.vpce.id]
}

# ECR Docker registry
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.this.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.ecr_dkr
  security_group_ids = [aws_security_group.vpce.id]
}

# S3 Gateway endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.this.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.aws_route_tables.private.ids
}

resource "aws_instance" "ec2" {
    ami = "ami-01102c5e8ab69fb75"
    instance_type = "t3a.micro"
    key_name = aws_key_pair.ec2.key_name
    monitoring = true
    associate_public_ip_address = false
    iam_instance_profile = aws_iam_instance_profile.this.name

    subnet_id              = var.private_ec2_subnet_id

    vpc_security_group_ids  = [aws_security_group.ec2_sg.id]

    user_data = base64encode(templatefile("${path.module}/user_data.tpl", {
    cluster_name = "${var.name}-cluster"
  }))
}