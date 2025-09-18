variable "ecs_port" {
  type = number
}

variable "database_port" {
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

variable "env_name" {
  type = string
}

variable "aws_account_id" {
  type = string
}