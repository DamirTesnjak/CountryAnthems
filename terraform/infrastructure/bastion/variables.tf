variable "name" {
  type = string
}

variable "vpc_id" {
    description = "Virtual Private Cloud ID"
    type = string
}

variable "bastion_public_subnet" {
    description = "Subnet inside VPC"
    type = string
}

variable "bastion_ingress" {
    description = "Your computer local IP address"
    type = string
}