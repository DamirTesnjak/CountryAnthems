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
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_1_us_west_2a"
  }
}

resource "aws_subnet" "private_2_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_2_us_west_2a"
  }
}

resource "aws_subnet" "public_3_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_3_us_west_2b"
  }
}

resource "aws_subnet" "private_4_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_4_us_west_2b"
  }
}

resource "aws_subnet" "public_5_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_5_us_west_2c"
  }
}

resource "aws_subnet" "private_6_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_6_us_west_2c"
  }
}

resource "aws_subnet" "private_7_us_west_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.7.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_7_us_west_2a"
  }
}

resource "aws_subnet" "private_8_us_west_2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.8.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_8_us_west_2b"
  }
}

resource "aws_subnet" "private_9_us_west_2c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.9.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_9_us_west_2c"
  }
}

resource "aws_subnet" "public_bastion" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_bastion"
  }
}
