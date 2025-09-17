variable "availability_zones" {
  type = list(string)
}

variable "bastion_sg_id" {
  type = string
}

variable "database_port" {
  type = number
}

variable "ecs_port" {
  type = number
}

variable "name" {
  type = string
}

variable "loadBalancer_port" {
  type = string
}

variable "bastion_ingress" {
  type = string
}

variable "public_route_table_id" {
  type = string
}

variable "vpc_endpoints_sg_id" {
  type = string
}