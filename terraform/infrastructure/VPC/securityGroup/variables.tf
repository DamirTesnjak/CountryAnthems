variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "database_port" {
  type = number
}

variable "ecs_port" {
  type = number
}

variable "loadBalancer_port" {
  type = number
}

variable "bastion_sg_id" {
  type = string
}

variable "bastion_ingress" {
  type = string
}

variable "vpc_endpoints_sg_id" {
  type = string
}

variable "db_subnet_cidr" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}