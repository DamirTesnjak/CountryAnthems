module "vpc" {
  source = "./VPC"

  availability_zones = ["us-west-2a", "us-west-2b"]
  db_port = var.db_port
  name = var.name
  ecs_port = var.ecs_port
}

module "rds" {
  source = "./RDS"

  security_group_db_id = module.vpc.security_group_db_id
  name            = var.name
  vpc_name        = module.vpc.vpc_name
}

module "s3" {
  source = "./S3"
}

module "ecr" {
  source = "./ECR"
}

module "ecs" {
  source = "./ECS"

  ecr_repository_name = module.ecr.ecr_repository_name
  bucket_domain_name = module.s3.bucket_domain_name
  vpc_id = module.vpc.vpc_id
  name = var.name
  port = var.ecs_port
}