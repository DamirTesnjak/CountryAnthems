resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_vpc_dhcp_options" "default" {
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dns_assoc" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.default.id
}

module "securityGroup" {
  source = "./securityGroup"

  vpc_id   = aws_vpc.main.id
  vpc_cidr_block = aws_vpc.main.cidr_block
  bastion_sg_id = var.bastion_sg_id
  database_port  = var.database_port
  ecs_port = var.ecs_port
  loadBalancer_port = var.loadBalancer_port
  bastion_ingress = var.bastion_ingress
  vpc_endpoints_sg_id = var.vpc_endpoints_sg_id
  db_subnet_cidr = aws_subnet.private_4b.cidr_block
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${data.aws_region.this.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_1a"
  }
}

resource "aws_subnet" "private_2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${data.aws_region.this.region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_2a"
  }
}

resource "aws_subnet" "public_3b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "${data.aws_region.this.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_3b"
  }
}

resource "aws_subnet" "private_4b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "${data.aws_region.this.region}b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_4b"
  }
}

resource "aws_subnet" "public_5c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "${data.aws_region.this.region}c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_5c"
  }
}

resource "aws_subnet" "private_6c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "${data.aws_region.this.region}c"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_6c"
  }
}

resource "aws_subnet" "public_bastion" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "${data.aws_region.this.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_bastion"
  }
}

# Associate subnets with public route table
resource "aws_route_table_association" "public_bastion" {
  subnet_id      = aws_subnet.public_bastion.id
  route_table_id = var.public_route_table_id
}

resource "aws_route_table_association" "association_public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = var.public_route_table_id
}

resource "aws_route_table_association" "association_public_3b" {
  subnet_id      = aws_subnet.public_3b.id
  route_table_id = var.public_route_table_id
}

resource "aws_route_table_association" "association_public_5c" {
  subnet_id      = aws_subnet.public_5c.id
  route_table_id = var.public_route_table_id
}
