# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints_sg" {
  name_prefix = "vpc-endpoints-"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name = "vpc-endpoints-sg"
  }
}

# Allows inbound HTTPS from ECS tasks
resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_from_ecs_task" {
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = var.ecs_sg_task_id
  security_group_id           = aws_security_group.vpc_endpoints_sg.id
  description                 = "HTTPS from ECS tasks"
}

# Allows inbound HTTPS from ECS
resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_from_ecs" {
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = var.ecs_sg_id
  security_group_id           = aws_security_group.vpc_endpoints_sg.id
  description                 = "HTTPS from ECS instance"
}

# Private subnets for VPC endpoints
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

# VPC Endpoints
#------------------------------------

# Allows ecs-agent, installed in EC2 API instance, via this endpoint to
# successfully connect to Amazon ECS-Agent, to register API EC2 to a cluster
resource "aws_vpc_endpoint" "ecs-agent" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecs-agent"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ecs-agent_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs-telemetry" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecs-telemetry"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ecs-telemetry_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecs" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecs"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ecs_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
}

# Allows EC2 API instance, via this endpoints to
# successfully connect to Amazon service, to pull docker image from ECR
resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ecr-dkr_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ecr-api_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true
}

# Allows EC2 API instance, via this endpoint to
# successfully connect to Amazon service, to connect to SSM, to get to SSM parameters 
resource "aws_vpc_endpoint" "ssm" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ssm_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ec2messages_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ec2messages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids          = local.ssmmessages_selected_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "ssmmessages-endpoint"
  }
}

# CloudWatch Logs endpoint (for logging)
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.cloud_watch_selected_subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "logs-endpoint"
  }
}

# Get all route tables in VPC (Virtual private cloud)
data "aws_route_tables" "all" {
  vpc_id = var.vpc_id
}


# S3 Gateway, needed fo pulling the docker image
resource "aws_vpc_endpoint" "S3-gateway" {
  vpc_id = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.region}.s3"
  vpc_endpoint_type = "Gateway"
    route_table_ids   = data.aws_route_tables.all.ids


  tags = {
    Name = "S3-gateway-endpoint"
  }
}

#------------------------------------

resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "${var.name}-ec2"
  public_key = tls_private_key.ec2.public_key_openssh
}

# genetrate .pem key for SSH connection
resource "local_file" "ec2-my-keys" {
  content = tls_private_key.ec2.private_key_pem
  filename = "${var.name}-ec2.pem"
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

# Launch template, to create new EC2 instance, from which API will
# be running
resource "aws_launch_template" "ec2_template" {
  name          = "ec2-template"
  image_id      = "ami-05f991e317f30f87a"
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
    security_groups             = [var.ecs_sg_id]
  }

    user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = "${var.name}-cluster"
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ECS Instance"
    }
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name = "asg"
  desired_capacity   = 1
  max_size           = 5
  min_size           = 1
  protect_from_scale_in = true
  vpc_zone_identifier = local.ecs-agent_selected_subnet_ids
  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
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

resource "aws_autoscaling_policy" "this" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  name                   = "${var.name}-cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50
  }
}

resource "aws_ecs_capacity_provider" "cp" {
  name = "EC2"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.autoscaling_group.arn
    managed_scaling {
      status                    = "DISABLED"
    }
  }
  depends_on = [var.loadBalancer_sg_id]
}

resource "aws_ecs_cluster_capacity_providers" "providers" {
  cluster_name = "${var.name}-cluster"
  capacity_providers = [aws_ecs_capacity_provider.cp.name]
  depends_on = [aws_ecs_capacity_provider.cp]
}