module "vpc" {
  source = "./VPC"

  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  bastion_sg_id = module.bastion.bastion_sg_id
  database_port            = var.database_port
  name               = "${var.name}-${var.env_name}"
  ecs_port           = var.ecs_port
  loadBalancer_port           = var.loadBalancer_port
  bastion_ingress = var.bastion_ingress
  public_route_table_id = module.cloud_front.public_route_table_id
  vpc_endpoints_sg_id = module.ec2.vpc_endpoints_sg_id
}

module "rds" {
  source = "./RDS"

  database_sg_id = module.vpc.database_sg_id
  bastion_id = module.bastion.bastion_id
  name                 = "${var.name}-${var.env_name}"
  vpc_name             = module.vpc.vpc_name
  database_subnets           = module.vpc.database_subnets
  database_user        = module.ecs.database_user
  bastion_public_ip = module.bastion.bastion_public_ip
  bastion_private_key = module.bastion.bastion_private_key
}

module "s3" {
  source = "./S3"

  vpc_id = module.vpc.vpc_id
  cloudFront_id  = module.cloud_front.cloudFront_id
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
  ecs_agent_subnets_id           = module.ec2.ecs_agent_subnets_id
  database_host = module.rds.database_host
  database_password = module.rds.database_password
  database_name = module.rds.database_name
  cloudfront_domain = module.cloud_front.cloudfront_domain
  capacity_provider_id = module.ec2.capacity_provider_id
  ecs_sg_task_id = module.vpc.ecs_sg_task_id
}

module "cloud_front" {
  source = "./CloudFront"

  loadBalancer_port              = var.loadBalancer_port
  name                  = "${var.name}-${var.env_name}"
  vpc_id                = module.vpc.vpc_id
  loadBalancer_subnets           = module.vpc.loadBalancer_subnets
  loadBalancer_sg_id = module.vpc.loadBalancer_sg_id
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  loadBalancer_tg_service_arn = module.ecs.loadBalancer_tg_service_arn
}

module "bastion" {
  source = "./bastion"

  name                  = "${var.name}-${var.env_name}"
  vpc_id                = module.vpc.vpc_id
  bastion_public_subnet = module.vpc.bastion_public_subnet
  bastion_ingress = var.bastion_ingress
}

module "ec2" {
  source = "./EC2"

  vpc_id                = module.vpc.vpc_id
  name                  = "${var.name}-${var.env_name}"
  loadBalancer_sg_id = module.vpc.loadBalancer_sg_id
  bastion_security_group_id = module.bastion.bastion_sg_id
  ecs_sg_task_id = module.vpc.ecs_sg_task_id
  ecs_sg_id = module.vpc.ecs_sg_id
}