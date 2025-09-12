resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "${var.name}-ec2"
  public_key = tls_private_key.ec2.public_key_openssh
}

resource "aws_ssm_parameter" "ec2-private-key" {
  name  = "/${var.name}/ec2/private-key"
  type  = "SecureString"
  value = tls_private_key.ec2.private_key_pem
}

resource "local_file" "ec2-my-keys" {
  content = tls_private_key.ec2.private_key_pem
  filename = "${var.name}-ec2.pem"
}

# Attach the AWS managed policy for ECS
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


# Instance Profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}


# Private route tables without internet access
resource "aws_route_table" "private" {
   vpc_id = var.vpc_id
   
   route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"  # This keeps traffic within the VPC
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

# S3 Gateway Endpoint (Free)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.this.region}.s3"
  route_table_ids = [aws_route_table.private.id]
}

# ECS Interface Endpoints
resource "aws_vpc_endpoint" "ecs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.ecs_control
  security_group_ids  = [var.security_group_vpc_endpoints_id]

  private_dns_enabled = true

  tags = {
    Name = "ecs-interface-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecs_agent" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.ecs_agent_subnets
  security_group_ids  = [var.security_group_vpc_endpoints_id]

  private_dns_enabled = true

  tags = {
    Name = "ecs-agent-interface-endpoint"
  }

}

resource "aws_vpc_endpoint" "ecs_telemetry" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.ecs_telemetry_subnets
  security_group_ids  = [var.security_group_vpc_endpoints_id]

  private_dns_enabled = true

  tags = {
    Name = "ecs-telemetry-interface-endpoint"
  }
}

# ECR Interface Endpoints
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.ecr_dkr_subnets
  security_group_ids  = [var.security_group_vpc_endpoints_id]

  private_dns_enabled = true

  tags = {
    Name = "ecr-dkr-interface-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.ecr_api_subnets
  security_group_ids  = [var.security_group_vpc_endpoints_id]

  private_dns_enabled = true

  tags = {
    Name = "ecr-api-interface-endpoint"
  }
}


# Launch template
resource "aws_launch_template" "this" {
  name          = "ec2-template"
  image_id      = data.aws_ami.ecs_optimized.id
  key_name      = aws_key_pair.ec2.key_name
  instance_type = "t3a.micro"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_size           = 50
      volume_type           = "gp2"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group_vpc_endpoints_id]
  }

    user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = "${var.name}-cluster"
  }))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "asg"
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  protect_from_scale_in = true
  vpc_zone_identifier = var.ecs_control
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

   instance_refresh {
    strategy = "Rolling"
    triggers = ["tag"]

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = "true"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = var.name
  }
}

resource "aws_ecs_capacity_provider" "cp" {
  name = "EC2"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.asg.arn
    managed_scaling {
      status                    = "DISABLED"
    }
  }
  depends_on = [var.security_group_alb_id]
}

resource "aws_ecs_cluster_capacity_providers" "providers" {
  cluster_name = "${var.name}-cluster"
  capacity_providers = [aws_ecs_capacity_provider.cp.name]

  default_capacity_provider_strategy {
    base = 1
    capacity_provider = aws_ecs_capacity_provider.cp.name
    weight            = 100
  }

  depends_on = [aws_ecs_capacity_provider.cp]
}

