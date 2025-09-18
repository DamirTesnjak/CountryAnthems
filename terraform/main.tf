provider "aws" {
  region = "us-west-2" # Type in your region
}

module "infrastructure" {
  source = "./infrastructure"

  name     = "country-anthems"
  env_name = "staging"
  bastion_ingress = local.bastion_ingress
  aws_account_id = local.aws_account_id
  database_port  = 5432
  ecs_port = 5001
  loadBalancer_port = 80
}