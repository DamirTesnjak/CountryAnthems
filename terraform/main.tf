provider "aws" {
  region = "us-west-2"
}

module "infrastructure" {
  source = "./infrastructure"

  name     = "country-anthems"
  env_name = "staging"
  bastion_ingress = local.bastion_ingress
  database_port  = 5432
  ecs_port = 5001
  loadBalancer_port = 80
}