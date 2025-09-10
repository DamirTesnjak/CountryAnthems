variable "vpc_id" {
  description = "VPC id value"
  type        = string
}

variable "name" {
  type = string
}

variable "private_ec2_subnet_id" {
  type = string
}

variable "ecs_control" {
  type = list(string)
}

variable "ecr_api" {
  type = list(string)
}

variable "ecr_dkr" {
  type = list(string)
}
