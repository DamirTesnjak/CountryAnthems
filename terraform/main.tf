provider "aws" {
  region = "us-west-2"
}

module "infrastructure" {
  source = "./infrastructure"

  name     = "country-anthems"
  bastion_ingress = local.bastion_ingress
  db_port  = 5432
  ecs_port = 5001
  alb_port = 80
}