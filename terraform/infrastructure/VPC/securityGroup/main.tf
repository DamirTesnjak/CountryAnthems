resource "aws_security_group" "security_group_alb" {
  name        = "Security_ALB"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id
}

# allowing connection to ALB
resource "aws_vpc_security_group_ingress_rule" "alb_allow_private" {
  description                  = "Allow connection from outside internet to access ALB"
  cidr_ipv4   = "0.0.0.0/0"
  from_port                    = 80
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.security_group_alb.id
  to_port                      = 80
}

# allowing output from ALB
resource "aws_vpc_security_group_egress_rule" "alb_allow_private" {
  description  = "Allow from ALB"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
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
  description                  = "Allow private to access ecs"
  from_port                    = var.ecs_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.security_group_alb.id
  security_group_id            = aws_security_group.security_group_ecs.id
  to_port                      = var.ecs_port
}

# allowing output from ECS
resource "aws_vpc_security_group_egress_rule" "ecs_allow_private" {
  description  = "Allow private from ecs"
  from_port                    = var.ecs_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.security_group_alb.id
  security_group_id = aws_security_group.security_group_ecs.id
  to_port                      = var.ecs_port
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
  description  = "Allow private from db"
  from_port   = var.db_port
  ip_protocol = "tcp"
  referenced_security_group_id = aws_security_group.security_group_ecs.id
  security_group_id = aws_security_group.security_group_db.id
  to_port     = var.db_port
}