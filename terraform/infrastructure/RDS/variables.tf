variable "name" {
    default = "country-anthems"
    type = string
}

variable "db_username" {
    type = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "security_group_db_id" {
  description = "The security groups to deploy the database in"
  type        = string
}
