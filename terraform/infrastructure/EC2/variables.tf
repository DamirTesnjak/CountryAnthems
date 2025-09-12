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

variable "ecs_agent_subnets" {
  type = list(string)
}

variable "ecs_telemetry_subnets" {
  type = list(string)
}

variable "ecr_dkr_subnets" {
  type = list(string)
}

variable "ecr_api_subnets" {
  type = list(string)
}

variable "ssm_subnets" {
  type = list(string)
}

variable "security_group_alb_id" {
  type = string
}

variable "bastion_ingress" {
  type = string
}

variable "security_group_vpc_endpoints_id" {
  type = string
}

variable "security_group_ecs_id" {
  type = string
}