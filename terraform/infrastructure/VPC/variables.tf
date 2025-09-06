variable "availability_zones" {
  type = list(string)
}

variable "security_group_EC2_id" {
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
