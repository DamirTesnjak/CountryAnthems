resource "random_string" "password" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "password" {
  name  = "postgres_password"
  type  = "SecureString"
  value = random_string.password.result
}

resource "aws_db_subnet_group" "rds-subnets" {
  name       = var.vpc_name
  subnet_ids = var.db_subnets

  tags = {
    Name = var.vpc_name
  }
}


resource "aws_db_instance" "this" {
  allocated_storage                   = 1
  db_name                             = "${var.name}-db"
  engine                              = "postgres"
  engine_version                      = "17.6"
  iam_database_authentication_enabled = false
  instance_class                      = "db.t4g.micro"
  username                            = data.aws_ssm_parameter.postgres_user
  password                            = random_string.password.result
  parameter_group_name                = "default.postgres17"
  db_subnet_group_name                = aws_db_subnet_group.rds-subnets.name
  publicly_accessible                 = false
  skip_final_snapshot                 = true
  vpc_security_group_ids              = [var.security_group_db_id]
}

resource "null_resource" "enable_postgis" {
  depends_on = [aws_db_instance.this]

  provisioner "local-exec" {
    command = <<EOT
PGPASSWORD=${random_string.password.result} psql \
  --host=${aws_db_instance.this.address} \
  --port=5432 \
  --username=${aws_db_instance.this.username} \
  --dbname=${aws_db_instance.this.db_name} \
  -c "CREATE EXTENSION IF NOT EXISTS postgis;"
EOT
  }
}