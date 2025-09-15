variable "vpc_id" {
  description = "VPC id value"
  type        = string
}

variable "name" {
  type = string
}

variable "private_subnet_config" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    "private-ecs-agent-2a" = {
      cidr_block        = "10.0.10.0/24"
      availability_zone = "us-west-2a"
    }
    "private-ecs-agent-2b" = {
      cidr_block        = "10.0.20.0/24"
      availability_zone = "us-west-2b"
    }
    "private-ecs-agent-2c" = {
      cidr_block        = "10.0.30.0/24"
      availability_zone = "us-west-2c"
    }
    "private-ecs-telemetry-2a" = {
      cidr_block        = "10.0.40.0/24"
      availability_zone = "us-west-2a"
    }
    "private-ecs-telemetry-2b" = {
      cidr_block        = "10.0.50.0/24"
      availability_zone = "us-west-2b"
    }
    "private-ecs-telemetry-2c" = {
      cidr_block        = "10.0.60.0/24"
      availability_zone = "us-west-2c"
    }
    "private-ecs-2a" = {
      cidr_block        = "10.0.70.0/24"
      availability_zone = "us-west-2a"
    }
    "private-ecs-2b" = {
      cidr_block        = "10.0.80.0/24"
      availability_zone = "us-west-2b"
    }
    "private-ecs-2c" = {
      cidr_block        = "10.0.90.0/24"
      availability_zone = "us-west-2c"
    }
    "private-ecr-dkr-2a" = {
      cidr_block        = "10.0.100.0/24"
      availability_zone = "us-west-2a"
    }
    "private-ecr-dkr-2b" = {
      cidr_block        = "10.0.110.0/24"
      availability_zone = "us-west-2b"
    }
    "private-ecr-dkr-2c" = {
      cidr_block        = "10.0.120.0/24"
      availability_zone = "us-west-2c"
    }
    "private-ecr-api-2a" = {
      cidr_block        = "10.0.130.0/24"
      availability_zone = "us-west-2a"
    }
    "private-ecr-api-2b" = {
      cidr_block        = "10.0.140.0/24"
      availability_zone = "us-west-2b"
    }
    "private-ecr-api-2c" = {
      cidr_block        = "10.0.150.0/24"
      availability_zone = "us-west-2c"
    }
    "private-ssm-2a" = {
      cidr_block        = "10.0.160.0/24"
      availability_zone = "us-west-2a"
    }
    "private-ssm-2b" = {
      cidr_block        = "10.0.170.0/24"
      availability_zone = "us-west-2b"
    }
    "private-ssm-2c" = {
      cidr_block        = "10.0.180.0/24"
      availability_zone = "us-west-2c"
    }
    "private-ec2messages-2a" = {
      cidr_block        = "10.0.190.0/24"
      availability_zone = "us-west-2a"
    }
    "private-ec2messages-2b" = {
      cidr_block        = "10.0.200.0/24"
      availability_zone = "us-west-2b"
    }
    "private-ec2messages-2c" = {
      cidr_block        = "10.0.210.0/24"
      availability_zone = "us-west-2c"
    }
    "private-ssmmessages-2a" = {
      cidr_block        = "10.0.220.0/24"
      availability_zone = "us-west-2a"
    }
    "private-ssmmessages-2b" = {
      cidr_block        = "10.0.230.0/24"
      availability_zone = "us-west-2b"
    }
    "private-ssmmessages-2c" = {
      cidr_block        = "10.0.240.0/24"
      availability_zone = "us-west-2c"
    }
    "private-cloudwatch-2a" = {
      cidr_block        = "10.0.230.0/24"
      availability_zone = "us-west-2a"
    }
    "private-cloudwatch-2b" = {
      cidr_block        = "10.0.240.0/24"
      availability_zone = "us-west-2b"
    }
    "private-cloudwatch-2c" = {
      cidr_block        = "10.0.250.0/24"
      availability_zone = "us-west-2c"
    }
  }
}

variable "security_group_alb_id" {
  type = string
}

variable "bastion_security_group_id" {
  type = string
}

variable "security_group_ecs_task_id" {
  type = string
}

variable "security_group_ecs_instance_id" {
  type = string
}


