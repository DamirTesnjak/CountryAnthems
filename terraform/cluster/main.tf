resource "aws_subnet" "API-private-us-west-2c" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.48.0/20"

  tags = {
    Name = "private-us-west-2a"
  }
}

data "aws_caller_identity" "this" {}

# RDS configurations

resource "aws_db_subnet_group" "country_anthems_database_subnets" {
  name       = "education"
  subnet_ids = [
    aws_subnet.private-database-us-west-2a.id,
    aws_subnet.private-database-us-west-2b.id
    ]

  tags = {
    Name = "country-Anthems-database"
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


resource "aws_subnet" "private-us-west-2c" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.48.0/20"

  tags = {
    Name = "private-us-west-2a"
  }
}

resource "aws_subnet" "private-us-west-2d" {
  vpc_id     = aws_vpc.country-anthems-vpc.id
  cidr_block = "10.0.64.0/20"

  tags = {
    Name = "private-us-west-2b"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.country_anthems_vpc.id
}

# connecting S3 bucket to VPC
resource "aws_vpc_endpoint" "country_anthems_s3_bucket" {
    vpc_id = aws_vpc.country_anthems_vpc.id
    service_network_arn = data.aws_s3_bucket.country_anthems_s3_bucket.arn
    vpc_endpoint_type = "Gateway"

    route_table_ids = [
        aws_route_table.private.id
    ]
}
