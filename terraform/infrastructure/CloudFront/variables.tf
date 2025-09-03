variable "vpc_id" {
  description = "VPC id value"
  type        = string
}

variable "name" {
  type = string
}

variable "alb_port" {
  type = number
}

variable "alb_subnets" {
  type = list(string)
}

variable "security_group_alb_id" {
  type = string
}