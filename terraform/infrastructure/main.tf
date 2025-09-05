module "vpc" {
  source = "./VPC"

  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  db_port            = var.db_port
  name               = var.name
  ecs_port           = var.ecs_port
  alb_port           = var.alb_port
}

module "rds" {
  source = "./RDS"

  security_group_db_id = module.vpc.security_group_db_id
  name                 = var.name
  vpc_name             = module.vpc.vpc_name
  db_subnets           = module.vpc.db_subnets
  postgres_user        = module.ecs.postgres_user
}

module "s3" {
  source = "./S3"

  vpc_id = module.vpc.vpc_id
  cf_id  = module.cloud_front.cf_id
  ecs_service_url = module.cloud_front.ecs_service_url
  aws_ecs_cluster_api_arn = module.ecs.aws_ecs_cluster_api_arn
}

module "ecr" {
  source = "./ECR"
}

module "ecs" {
  source = "./ECS"

  image_registry    = "${data.aws_caller_identity.this.account_id}.dkr.ecr.${data.aws_region.this.region}.amazonaws.com"
  image_repository  = module.ecr.ecr_repository_name
  image_tag         = var.name
  bucket_domain_name    = module.s3.bucket_domain_name
  vpc_id                = module.vpc.vpc_id
  name                  = var.name
  port                  = var.ecs_port
  ecs_subnets           = module.vpc.ecs_subnets
  security_group_ecs_id = module.vpc.security_group_ecs_id
}

module "cloud_front" {
  source = "./CloudFront"

  alb_port              = var.alb_port
  name                  = var.name
  vpc_id                = module.vpc.vpc_id
  alb_subnets           = module.vpc.alb_subnets
  security_group_alb_id = module.vpc.security_group_alb_id
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
}