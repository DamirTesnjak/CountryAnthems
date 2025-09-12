resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_vpc_dhcp_options" "default" {
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dns_assoc" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.default.id
}

module "securityGroup" {
  source = "./securityGroup"

  vpc_id   = aws_vpc.main.id
  security_group_bastion_id = var.security_group_bastion_id
  db_port  = var.db_port
  ecs_port = var.ecs_port
  alb_port = var.alb_port
  bastion_ingress = var.bastion_ingress
}

resource "aws_subnet" "public_1_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_1_us_west_2a"
  }
}

resource "aws_subnet" "private_2_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_2_us_west_2a"
  }
}

resource "aws_subnet" "public_3_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_3_us_west_2b"
  }
}

resource "aws_subnet" "private_4_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_4_us_west_2b"
  }
}

resource "aws_subnet" "public_5_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_5_us_west_2c"
  }
}

resource "aws_subnet" "private_6_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_6_us_west_2c"
  }
}

resource "aws_subnet" "private_7_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.7.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_7_us_west_2a"
  }
}

resource "aws_subnet" "private_8_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.8.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_8_us_west_2b"
  }
}

resource "aws_subnet" "private_9_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.9.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_9_us_west_2c"
  }
}

resource "aws_subnet" "public_bastion" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_bastion"
  }
}

resource "aws_subnet" "private_ec2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet_ec2"
  }
}

resource "aws_subnet" "ecs-control-plane_private_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecs-control-plane_private_us_west_2a"
  }
}

resource "aws_subnet" "ecs-control-plane_private_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.30.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecs-control-plane_private_us_west_2b"
  }
}

resource "aws_subnet" "ecs-control-plane_private_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.40.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecs-control-plane_private_us_west_2c"
  }
}


resource "aws_subnet" "ecs_agent_private_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.50.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecs_agent_private_us_west_2a"
  }
}

resource "aws_subnet" "ecs_agent_private_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.60.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecs_agent_private_us_west_2b"
  }
}

resource "aws_subnet" "ecs_agent_private_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.70.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecs_agent_private_us_west_2c"
  }
}

resource "aws_subnet" "ecs_telemetry_private_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.80.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecs_telemetry_private_us_west_2a"
  }
}

resource "aws_subnet" "ecs_telemetry_private_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.90.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecs_telemetry_private_us_west_2b"
  }
}

resource "aws_subnet" "ecs_telemetry_private_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.100.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecs_telemetry_private_us_west_2c"
  }
}

resource "aws_subnet" "ecr_dkr_private_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.110.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecr_dkr_private_us_west_2a"
  }
}

resource "aws_subnet" "ecr_dkr_private_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.120.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecr_dkr_private_us_west_2b"
  }
}

resource "aws_subnet" "ecr_dkr_private_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.130.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecr_dkr_private_us_west_2c"
  }
}

resource "aws_subnet" "ecr_api_private_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.140.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecr_api_private_us_west_2a"
  }
}

resource "aws_subnet" "ecr_api_private_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.150.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecr_api_private_us_west_2b"
  }
}

resource "aws_subnet" "ecr_api_private_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.160.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "ecr_api_private_us_west_2c"
  }
}

resource "aws_subnet" "ssm_private_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.170.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "ssm_private_us_west_2a"
  }
}

resource "aws_subnet" "ssm_private_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.180.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "ssm_private_us_west_2b"
  }
}

resource "aws_subnet" "ssm_private_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.190.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "ssm_private_us_west_2c"
  }
}

# Associate subnets with public route table
resource "aws_route_table_association" "public_bastion" {
  subnet_id      = aws_subnet.public_bastion.id
  route_table_id = var.aws_route_table_public_id
}

resource "aws_route_table_association" "public_1_us_west_2a" {
  subnet_id      = aws_subnet.public_1_us_west_2a.id
  route_table_id = var.aws_route_table_public_id
}

resource "aws_route_table_association" "public_3_us_west_2b" {
  subnet_id      = aws_subnet.public_3_us_west_2b.id
  route_table_id = var.aws_route_table_public_id
}

resource "aws_route_table_association" "public_5_us_west_2c" {
  subnet_id      = aws_subnet.public_5_us_west_2c.id
  route_table_id = var.aws_route_table_public_id
}

resource "aws_route_table_association" "ecs-control-plane_private_us_west_2a" {
  subnet_id      = aws_subnet.ecs-control-plane_private_us_west_2a.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecs-control-plane_private_us_west_2b" {
  subnet_id      = aws_subnet.ecs-control-plane_private_us_west_2b.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecs-control-plane_private_us_west_2c" {
  subnet_id      = aws_subnet.ecs-control-plane_private_us_west_2c.id
  route_table_id = var.route_table_private_id
}


resource "aws_route_table_association" "ecs_agent_private_us_west_2a" {
  subnet_id      = aws_subnet.ecs_agent_private_us_west_2a.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecs_agent_private_us_west_2b" {
  subnet_id      = aws_subnet.ecs_agent_private_us_west_2b.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecs_agent_private_us_west_2c" {
  subnet_id      = aws_subnet.ecs_agent_private_us_west_2c.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecs_telemetry_private_us_west_2a" {
  subnet_id      = aws_subnet.ecs_telemetry_private_us_west_2a.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecs_telemetry_private_us_west_2b" {
  subnet_id      = aws_subnet.ecs_telemetry_private_us_west_2b.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecs_telemetry_private_us_west_2c" {
  subnet_id      = aws_subnet.ecs_telemetry_private_us_west_2c.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecr_dkr_private_us_west_2a" {
  subnet_id      = aws_subnet.ecr_dkr_private_us_west_2a.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecr_dkr_private_us_west_2b" {
  subnet_id      = aws_subnet.ecr_dkr_private_us_west_2b.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecr_dkr_private_us_west_2c" {
  subnet_id      = aws_subnet.ecr_dkr_private_us_west_2c.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecr_api_private_us_west_2a" {
  subnet_id      = aws_subnet.ecr_api_private_us_west_2a.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecr_api_private_us_west_2b" {
  subnet_id      = aws_subnet.ecr_api_private_us_west_2b.id
  route_table_id = var.route_table_private_id
}

resource "aws_route_table_association" "ecr_api_private_us_west_2c" {
  subnet_id      = aws_subnet.ecr_api_private_us_west_2c.id
  route_table_id = var.route_table_private_id
}
