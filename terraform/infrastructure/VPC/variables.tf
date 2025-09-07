variable "availability_zones" {
  type = list(string)
}

variable "security_group_bastion_id" {
  type = string
}

variable "db_port" {
  type = number
}

variable "ecs_port" {
  type = number
}

variable "name" {
  type = string
}

variable "alb_port" {
  type = string
}

variable "bastion_ingress" {
  type = string
}

variable "aws_route_table_public_id" {
  type = string
}
