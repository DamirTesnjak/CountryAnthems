module "vpc" {
  source = "./VPC"

  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  security_group_bastion_id = module.bastion.security_group_bastion_id
  db_port            = var.db_port
  name               = "${var.name}-${var.env_name}"
  ecs_port           = var.ecs_port
  alb_port           = var.alb_port
  bastion_ingress = var.bastion_ingress
  aws_route_table_public_id = module.cloud_front.aws_route_table_public_id
  vpc_endpoints_sg_id = module.ec2.vpc_endpoints_sg_id
}

module "rds" {
  source = "./RDS"

  security_group_db_id = module.vpc.security_group_db_id
  aws_instance_bastion_id = module.bastion.aws_instance_bastion_id
  name                 = "${var.name}-${var.env_name}"
  vpc_name             = module.vpc.vpc_name
  db_subnets           = module.vpc.db_subnets
  db_user        = module.ecs.db_user
  bastion_public_ip = module.bastion.bastion_public_ip
  bastion_private_key = module.bastion.bastion_private_key
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

  image_tag         = var.env_name
  name                  = "${var.name}-${var.env_name}"
}

module "ecs" {
  source = "./ECS"

  image_registry    = "${data.aws_caller_identity.this.account_id}.dkr.ecr.${data.aws_region.this.region}.amazonaws.com"
  image_repository  = module.ecr.ecr_repository_name
  image_tag         = var.env_name
  bucket_domain_name    = module.s3.bucket_domain_name
  vpc_id                = module.vpc.vpc_id
  name                  = "${var.name}-${var.env_name}"
  port                  = var.ecs_port
  ecs_agent_subnets           = module.ec2.ecs_agent_subnets
  pg_host = module.rds.pg_host
  pg_password = module.rds.pg_password
  pg_db = module.rds.pg_db
  cloudfront_domain = module.cloud_front.cloudfront_domain
  capacity_provider_id = module.ec2.capacity_provider_id
  security_group_ecs_task_id = module.vpc.security_group_ecs_task_id
}

module "cloud_front" {
  source = "./CloudFront"

  alb_port              = var.alb_port
  name                  = "${var.name}-${var.env_name}"
  vpc_id                = module.vpc.vpc_id
  alb_subnets           = module.vpc.alb_subnets
  security_group_alb_id = module.vpc.security_group_alb_id
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  aws_lb_target_group_service_arn = module.ecs.aws_lb_target_group_service_arn
}

module "bastion" {
  source = "./bastion"

  name                  = "${var.name}-${var.env_name}"
  vpc_id                = module.vpc.vpc_id
  public_subnet_bastion = module.vpc.public_subnet_bastion
  bastion_ingress = var.bastion_ingress
}

module "ec2" {
  source = "./EC2"

  vpc_id                = module.vpc.vpc_id
  name                  = "${var.name}-${var.env_name}"
  security_group_alb_id = module.vpc.security_group_alb_id
  bastion_security_group_id = module.bastion.security_group_bastion_id
  security_group_ecs_task_id = module.vpc.security_group_ecs_task_id
  security_group_ecs_instance_id = module.vpc.security_group_ecs_instance_id
}