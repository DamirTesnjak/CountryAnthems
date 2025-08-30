resource "aws_ecr_repository" "country_anthems_api_docker_image" {
    name = var.ecr_repository_name_api
    image_tag_mutability = "IMMUTABLE"
    encryption_type = "AES256"
}


# S3 - bucket configs

resource "aws_s3_bucket" "country_anthems_s3_bucket" {
    bucket = var.country_anthems_S3_bucket_name
    force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.country_anthems_s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.country_anthems_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.country_anthems_s3_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

# RDS configurations
resource "random_string" "password" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "password" {
  name  = "/${var.name}/database/password"
  type  = "SecureString"
  value = random_string.password.result
}

resource "aws_db_subnet_group" "country-anthems-database" {
  name       = "education"
  subnet_ids = [
    aws_subnet.private-database-us-west-2a.id,
    aws_subnet.private-database-us-west-2b.id
    ]

  tags = {
    Name = "country-Anthems-database"
  }
}


resource "aws_db_instance" "postgres" {
  allocated_storage    = 1
  create_db_option_group              = false
  create_db_parameter_group           = false
  create_db_subnet_group              = false
  create_monitoring_role              = false
  db_name              = "country-anthems-postgres-database"
  engine               = "postgres"
  engine_version       = "17.6"
    iam_database_authentication_enabled = false
  instance_class       = "db.t4g.micro"
  username             = "postgres"
  password             = random_string.password.result
  parameter_group_name = "default.postgres17"
  publicly_accessible = false
  skip_final_snapshot  = true
}

resource "null_resource" "enable_postgis" {
  depends_on = [aws_db_instance.postgres]

  provisioner "local-exec" {
    command = <<EOT
PGPASSWORD=${random_string.password.result} psql \
  --host=${aws_db_instance.postgres.address} \
  --port=5432 \
  --username=${aws_db_instance.postgres.username} \
  --dbname=${aws_db_instance.postgres.db_name} \
  -c "CREATE EXTENSION IF NOT EXISTS postgis;"
EOT
  }
}

# VPC configurations

data "aws_region" "current" {}

# get bucket ARN
data "aws_s3_bucket" "country_anthems_s3_bucket" {
    arn = aws_s3_bucket.country_anthems_s3_bucket.arn
}

resource "aws_vpc" "country-anthems-vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    avability_zone = ["us-west-2a", "us-west-2b"]

    tags = {
        Name = "country-anthems-vpc"
    }
}

resource "aws_subnet" "private-database-us-west-2a" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.16.0/20"

  tags = {
    Name = "private-database-us-west-2a"
  }
}

resource "aws_subnet" "private-database-us-west-2b" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.32.0/20"

  tags = {
    Name = "private-database-us-west-2b"
  }
}


resource "aws_subnet" "private-us-west-2a" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.48.0/20"

  tags = {
    Name = "private-us-west-2a"
  }
}

resource "aws_subnet" "private-us-west-2b" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.64.0/20"

  tags = {
    Name = "private-us-west-2b"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.country_anthems_vpc.id
}

resource "aws_vpc_endpoint" "country_anthems_s3_bucket" {
    vpc_id = aws_vpc.country_anthems_vpc.id
    service_network_arn = data.aws_s3_bucket.country_anthems_s3_bucket.arn
    vpc_endpoint_type = "Gateway"

    route_table_ids = [
        aws_route_table.private.id
    ]
}
