provider "aws" {
  region = "us-west-2"
}

module "infrastructure" {
  source = "./infrastructure"

  name     = "country-anthems"
  bastion_ingress = local.bastion_ingress
  db_port  = 5432
  ecs_port = 8080
  alb_port = 80
}