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

variable "ecs_agent_subnets_id" {
  type = list(string)
}

variable "ecs_sg_task_id" {
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

variable "database_host" {
  type = string
}

variable "database_password" {
  type = string
}

variable "database_name" {
  type = string
}

variable "cloudfront_domain" {
  type = string
}

variable "capacity_provider_id" {
  type = string
}