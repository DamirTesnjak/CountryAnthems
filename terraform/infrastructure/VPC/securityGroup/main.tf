resource "aws_security_group" "security_group_alb" {
  name        = "Security_ALB"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id
}

# allowing connection to ALB
resource "aws_vpc_security_group_ingress_rule" "alb_allow_private" {
  description       = "Allow connection from outside internet to access ALB"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.alb_port
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.security_group_alb.id
  to_port           = var.alb_port
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = "sg-02809867956458a69"
  
  description = "HTTPS from internet"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
  
  tags = {
    Name = "ALB HTTPS Ingress"
  }
}


# allowing output from ALB
resource "aws_vpc_security_group_egress_rule" "alb_allow_private" {
  description       = "Allow from ALB"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.security_group_alb.id
}

#------------------------------------------------------------------------------

resource "aws_security_group" "ecs_instance" {
  name        = "Security_ECS"
  description = "Security group for ECS"
  vpc_id      = var.vpc_id
}

# allowing connection to ECS
resource "aws_vpc_security_group_ingress_rule" "ecs_allow_private" {
  description                  = "HTTP from ALB"
  from_port                    = var.ecs_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.security_group_alb.id
  security_group_id            = aws_security_group.ecs_instance.id
  to_port                      = var.ecs_port
}

# allowing output from ECS
resource "aws_vpc_security_group_egress_rule" "ecs_allow_private" {
  description                  = "Allow private from ecs"
  from_port                    = var.ecs_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.security_group_alb.id
  security_group_id            = aws_security_group.ecs_instance.id
  to_port                      = var.ecs_port
}

# SSH access (optional)
resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "10.0.0.0/16"  # Your VPC CIDR
  security_group_id = aws_security_group.ecs_instance.id
  description       = "SSH access from VPC"
}

# Egress rule: Allow HTTPS outbound
resource "aws_vpc_security_group_egress_rule" "vpc_endpoints_https_outbound" {
  security_group_id = aws_security_group.ecs_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow HTTPS outbound"
}

# Egress rule: Allow HTTP outbound
resource "aws_vpc_security_group_egress_rule" "vpc_endpoints_http_outbound" {
  security_group_id = aws_security_group.ecs_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP outbound"
}

# Egress rule: Allow DNS outbound
resource "aws_vpc_security_group_egress_rule" "vpc_endpoints_dns_outbound" {
  security_group_id = aws_security_group.ecs_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"
  description       = "Allow DNS outbound"
}


# All outbound traffic (for ECS agent, Docker pulls, etc.)
resource "aws_vpc_security_group_egress_rule" "ec2_all_outbound" {
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.ecs_instance.id
  description       = "All outbound traffic"
}


#------------------------------------------------------------------------------

resource "aws_security_group" "security_group_db" {
  name        = "Security_DB"
  description = "Security group for database"
  vpc_id      = var.vpc_id
}

# allowing connection to DB
resource "aws_vpc_security_group_ingress_rule" "db_from_ecs" {
  description                  = "Allow private to access db"
  from_port                    = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_tasks.id
  security_group_id            = aws_security_group.security_group_db.id
  to_port                      = var.db_port
}

# allowing output from DB
resource "aws_vpc_security_group_egress_rule" "db_to_ecs" {
  description                  = "Allow private from db"
  from_port                    = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_tasks.id
  security_group_id            = aws_security_group.security_group_db.id
  to_port                      = var.db_port
}


#------------------------------------------------------------------------------

resource "aws_security_group" "bastion_to_rds" {
  name        = "Security_EC2_RDS"
  description = "Security group for database"
  vpc_id      = var.vpc_id
}

# allowing connection to DB from EC2
resource "aws_vpc_security_group_ingress_rule" "bastion_to_rds" {
  description                  = "Allow private to access db"
  from_port                    = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.security_group_bastion_id
  security_group_id            = aws_security_group.security_group_db.id
  to_port                      = var.db_port
}

# allowing output from DB
resource "aws_vpc_security_group_egress_rule" "bastion_to_rds" {
  description                  = "Allow private from db"
  from_port                    = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.security_group_bastion_id
  security_group_id            = aws_security_group.security_group_db.id
  to_port                      = var.db_port
}

#---------------------------------------------------------------------------------------------------

# Security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "ecs-tasks-"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ecs-tasks-sg"
  }
}

# Outbound HTTPS to VPC endpoints (for ECR access)
resource "aws_vpc_security_group_egress_rule" "ecs_to_vpc_endpoints_https" {
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = var.vpc_endpoints_sg_id
  security_group_id           = aws_security_group.ecs_tasks.id
  description                 = "HTTPS to VPC endpoints"
}

# Outbound DNS (for name resolution)
resource "aws_vpc_security_group_egress_rule" "ecs_dns_udp" {
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.ecs_tasks.id
  description       = "DNS UDP"
}

resource "aws_vpc_security_group_egress_rule" "ecs_dns_tcp" {
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.ecs_tasks.id
  description       = "DNS TCP"
}

# Optional: If you need internet access (for non-ECR registries)
resource "aws_vpc_security_group_egress_rule" "ecs_internet_https" {
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.ecs_tasks.id
  description       = "HTTPS to internet"
}

# Optional: HTTP for package updates, etc.
resource "aws_vpc_security_group_egress_rule" "ecs_internet_http" {
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.ecs_tasks.id
  description       = "HTTP to internet"
}

# Allow ALB to reach ECS tasks on port 5001
resource "aws_vpc_security_group_ingress_rule" "ecs_task_allow_alb" {
  security_group_id = aws_security_group.ecs_tasks.id
  
  description = "Allow ALB to reach ECS tasks on port 5001"
  
  from_port   = var.ecs_port
  to_port     = var.ecs_port
  ip_protocol = "tcp"
  
  referenced_security_group_id = aws_security_group.security_group_alb.id
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_database" {
  security_group_id = aws_security_group.ecs_tasks.id

  description = "Allow ECS tasks to connect to PostgreSQL database"
  ip_protocol = "tcp"
  from_port   = var.db_port
  to_port     = var.db_port
  cidr_ipv4   = "10.0.0.0/16"  # Allow entire VPC
}
