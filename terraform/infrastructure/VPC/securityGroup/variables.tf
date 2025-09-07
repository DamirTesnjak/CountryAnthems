variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "db_port" {
  type = number
}

variable "ecs_port" {
  type = number
}

variable "alb_port" {
  type = number
}

variable "security_group_bastion_id" {
  type = string
}

variable "bastion_ingress" {
  type = string
}