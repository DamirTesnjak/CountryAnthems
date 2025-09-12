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

# allowing output from ALB
resource "aws_vpc_security_group_egress_rule" "alb_allow_private" {
  description       = "Allow from ALB"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.security_group_alb.id
}

#------------------------------------------------------------------------------

resource "aws_security_group" "security_group_ecs" {
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
  security_group_id            = aws_security_group.security_group_ecs.id
  to_port                      = var.ecs_port
}

resource "aws_vpc_security_group_ingress_rule" "ecs_allow_private_2" {
  description                  = "HTTPS from ALB"
  from_port                    = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.security_group_alb.id
  security_group_id            = aws_security_group.security_group_ecs.id
  to_port                      = 443
}

# allowing output from ECS
resource "aws_vpc_security_group_egress_rule" "ecs_allow_private" {
  description                  = "Allow private from ecs"
  from_port                    = var.ecs_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.security_group_alb.id
  security_group_id            = aws_security_group.security_group_ecs.id
  to_port                      = var.ecs_port
}

resource "aws_security_group_rule" "ecs_outbound_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Or just VPC CIDR: ["10.0.0.0/16"]
  security_group_id = aws_security_group.security_group_ecs.id
}


#------------------------------------------------------------------------------

resource "aws_security_group" "security_group_db" {
  name        = "Security_DB"
  description = "Security group for database"
  vpc_id      = var.vpc_id
}

# allowing connection to DB
resource "aws_vpc_security_group_ingress_rule" "db_allow_private" {
  description                  = "Allow private to access db"
  from_port                    = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.security_group_ecs.id
  security_group_id            = aws_security_group.security_group_db.id
  to_port                      = var.db_port
}

# allowing output from DB
resource "aws_vpc_security_group_egress_rule" "db_allow_private" {
  description                  = "Allow private from db"
  from_port                    = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.security_group_ecs.id
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
resource "aws_security_group" "vpc_endpoints" {
  name        = "Security_VPC_endpoints"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "vpc_endpoint_from_ecs" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.security_group_ecs.id  # ECS instances SG
  security_group_id        = aws_security_group.vpc_endpoints.id  # VPC endpoint SG
}


resource "aws_vpc_security_group_ingress_rule" "allow_from_EC2_2" {
  description                  = "Allow traffic from EC2"
  cidr_ipv4 = "10.0.0.0/16"
  from_port                    = 22
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.vpc_endpoints.id
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.vpc_endpoints.id
}

#---------------------------------------------------------------------------------------------------
