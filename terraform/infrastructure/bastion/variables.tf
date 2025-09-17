variable "name" {
  type = string
}

variable "vpc_id" {
    description = "Virtual Private Cloud ID"
    type = string
}

variable "bastion_public_subnet" {
    type = string
}

variable "bastion_ingress" {
    type = string
}