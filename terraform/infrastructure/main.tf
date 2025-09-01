module "vpc" {
  source = "./VPC"

  availability_zones = ["us-west-2a", "us-west-2b"]
  db_port = var.db_port
}

module "rds" {
  source = "./RDS"

  security_group_db_id = module.vpc.security_group_db_id
  subnets         = module.vpc.database_subnets
  name            = var.name
  vpc_name        = module.vpc.vpc_name
}

module "ecr" {
  source = "./ECR"
}

module "ecs" {
  source = "./ECS"

  ecr_repository_name = module.ecr.ecr_repository_name
  bucket_domain_name = module.ecr.bucket_domain_name
  vpc_id = module.vpc.vpc_id
  name = var.name
  port = var.ecs_port
}