variable "vpc_id" {
  description = "VPC id value"
  type        = string
}

variable "name" {
  type = string
}

variable "port" {
  type = number
}

variable "bucket_domain_name" {
  type = string
}

variable "ecs_subnets" {
  type = list(string)
}

variable "security_group_ecs_id" {
  type = string
}

variable "image_registry" {
  type = string
}

variable "image_repository" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "pg_host" {
  type = string
}

variable "pg_password" {
  type = string
}

variable "pg_db" {
  type = string
}

variable "cloudfront_domain" {
  type = string
}
