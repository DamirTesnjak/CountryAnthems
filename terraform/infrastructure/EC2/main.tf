# Subnets
resource "aws_subnet" "private" {
  for_each = var.private_subnet_config

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = each.key
    Type = "Private"
  }
}

# Security group
resource "aws_security_group" "vpc_endpoints" {
  name        = "Security_VPC_endpoints"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_internal_ingress" {
  ip_protocol = "-1"
  referenced_security_group_id = aws_security_group.vpc_endpoints.id
  security_group_id = aws_security_group.vpc_endpoints.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_internal_egress" {
  ip_protocol = "-1"
  referenced_security_group_id = aws_security_group.vpc_endpoints.id
  security_group_id = aws_security_group.vpc_endpoints.id
}

# ECS VPC Endpoints
resource "aws_vpc_endpoint" "ecs-agent" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecs-agent"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ecs-agent_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs-telemetry" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecs-telemetry"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ecs-telemetry_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecs"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ecs_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

# ECR VPC Endpoints
resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ecr-dkr_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecr-api"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ecr-api_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

# System manager VPC Endpoints
resource "aws_vpc_endpoint" "ssm" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ssm_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ec2messages_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ssmmessages_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}

# S3 Gateway
resource "aws_vpc_endpoint" "S3-gateway" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.s3"
  vpc_endpoint_type = "Gateway"
  security_group_ids = [aws_security_group.vpc_endpoints.id]
}

#Private key
resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "${var.name}-ec2"
  public_key = tls_private_key.ec2.public_key_openssh
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = var.name
}

# Attach the AWS managed policy for ECS
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "this" {
  name = var.name
  role = aws_iam_role.this.name
}

# Launch template
resource "aws_launch_template" "this" {
  name          = "ec2-template"
  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
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
    name = aws_iam_instance_profile.this.name
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.vpc_endpoints.id]
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
  max_size           = 5
  min_size           = 1
  protect_from_scale_in = true
  vpc_zone_identifier = local.ecs-agent_selected_subnet_ids
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