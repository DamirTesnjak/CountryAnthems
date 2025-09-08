variable "name" {
  default = "country-anthems"
  type    = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "security_group_db_id" {
  description = "The security groups to deploy the database in"
  type        = string
}

variable "aws_instance_bastion_id" {
  type = string
}

variable "db_subnets" {
  type = list(string)
}

variable "db_user" {
  type = string
}

variable "bastion_public_ip" {
  type = string
}

variable "bastion-private-key" {
  type = string
}