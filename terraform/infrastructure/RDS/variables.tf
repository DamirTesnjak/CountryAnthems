variable "name" {
  default = "country-anthems"
  type    = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "database_sg_id" {
  description = "The security groups to deploy the database in"
  type        = string
}

variable "bastion_id" {
  description = "Bastion ID"
  type = string
}

variable "database_subnets" {
  type = list(string)
}

variable "database_username" {
  description = "Username for loggin to database"
  type = string
}

variable "bastion_public_ip" {
  description = "EC2 Bastion public IP"
  type = string
}

variable "bastion_private_key" {
  type = string
}