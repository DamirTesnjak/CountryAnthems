resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main-vpc"
  }
}

module "securityGroup" {
  source = "./securityGroup"

  vpc_id   = aws_vpc.main.id
  db_port  = var.db_port
  ecs_port = var.ecs_port
  alb_port = var.alb_port
}

resource "aws_subnet" "public_1_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.0.0/16"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_1_us_west_2a"
  }
}

resource "aws_subnet" "private_2_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.2.0.0/16"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_2_us_west_2a"
  }
}

resource "aws_subnet" "public_3_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.3.0.0/16"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_3_us_west_2b"
  }
}

resource "aws_subnet" "private_4_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.4.0.0/16"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_4_us_west_2b"
  }
}

resource "aws_subnet" "public_5_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.5.0.0/16"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_5_us_west_2c"
  }
}

resource "aws_subnet" "private_6_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.6.0.0/16"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_6_us_west_2c"
  }
}

resource "aws_subnet" "private_7_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.7.0.0/16"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_7_us_west_2a"
  }
}

resource "aws_subnet" "private_8_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.8.0.0/16"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_8_us_west_2b"
  }
}

resource "aws_subnet" "private_9_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.9.0.0/16"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_9_us_west_2c"
  }
}