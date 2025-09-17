variable "vpc_id" {
  description = "VPC id value"
  type        = string
}

variable "name" {
  type = string
}

variable "loadBalancer_port" {
  type = number
}

variable "loadBalancer_subnets" {
  type = list(string)
}

variable "loadBalancer_sg_id" {
  type = string
}

variable "bucket_regional_domain_name" {
  type = string
}

variable "loadBalancer_tg_service_arn" {
  type = string
}