# Creates random database password
resource "random_string" "password" {
  length  = 32
  special = false
}

# Stores the random password in SSM parameters
resource "aws_ssm_parameter" "password" {
  name  = "postgres_password"
  type  = "SecureString"
  value = random_string.password.result
}

# During creation of the database instance we define
# its subnets. AWS with its own algorithm will assign
# database subnet
resource "aws_db_subnet_group" "rds-subnets" {
  name       = var.vpc_name
  subnet_ids = var.database_subnets

  tags = {
    Name = var.vpc_name
  }
}

# New instance od a database
resource "aws_db_instance" "db_instance" {
  allocated_storage                   = 20
  db_name                             = "geo"
  engine                              = "postgres"
  engine_version                      = "17.6"
  iam_database_authentication_enabled = false
  instance_class                      = "db.t4g.micro"
  username                            = var.database_username
  password                            = random_string.password.result
  parameter_group_name                = "default.postgres17"
  db_subnet_group_name                = aws_db_subnet_group.rds-subnets.name
  publicly_accessible                 = false
  skip_final_snapshot                 = true
  vpc_security_group_ids              = [var.database_sg_id]
  port = 5432
}

# Populates database with data with SQL and bash scripts,
# through bastion instance
resource "null_resource" "import_geojson" {
  triggers = {
    bastion_id = var.bastion_id
  }
  depends_on = [aws_db_instance.db_instance]

  connection {
    type        = "ssh"
    host        = var.bastion_public_ip
    user        = "ubuntu"
    private_key = var.bastion_private_key
  }

  provisioner "file" {
    source      = "${path.module}/migrations/01_init.sql"
    destination = "/tmp/init.sql"
  }

  provisioner "file" {
    source      = "${path.module}/migrations/02_import.sh"
    destination = "/tmp/import.sh"
  }

  provisioner "file" {
    source      = "${path.module}/migrations/countries.geojson"
    destination = "/tmp/countries.geojson"
  }

  provisioner "file" {
    source      = "${path.module}/migrations/countries_capitals_anthems.json"
    destination = "/tmp/countries_capitals_anthems.json"
  }

  provisioner "file" {
    source      = "${path.module}/migrations/03_update.sql"
    destination = "/tmp/update.sql"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y postgresql-client gdal-bin dos2unix",
      "PGPASSWORD='${random_string.password.result}' psql -v ON_ERROR_STOP=1 -h ${aws_db_instance.db_instance.address} -p ${aws_db_instance.db_instance.port} -U ${var.database_username} -d ${aws_db_instance.db_instance.db_name} -c \"CREATE EXTENSION IF NOT EXISTS postgis;\"",
      "PGPASSWORD='${random_string.password.result}' psql -v ON_ERROR_STOP=1 -h ${aws_db_instance.db_instance.address} -p ${aws_db_instance.db_instance.port} -U ${var.database_username} -d ${aws_db_instance.db_instance.db_name} --file=/tmp/init.sql",
      "dos2unix /tmp/import.sh", # use this if bash script was created in Windows
      "chmod +x /tmp/import.sh", # allows premission to run a bash script
      "export PGHOST=${aws_db_instance.db_instance.address}",
      "export PGPORT=${aws_db_instance.db_instance.port}",
      "export POSTGRES_USER=${var.database_username}",
      "export POSTGRES_PASSWORD=${random_string.password.result}",
      "export POSTGRES_DB=${aws_db_instance.db_instance.db_name}",
      "/tmp/import.sh",
      "sed \"s|__DATA_PATH__|/tmp/countries_capitals_anthems.json|g\" /tmp/update.sql > /tmp/update_parsed.sql",
      "PGPASSWORD='${random_string.password.result}' psql -v ON_ERROR_STOP=1 -h ${aws_db_instance.db_instance.address} -p ${aws_db_instance.db_instance.port} -U ${var.database_username} -d ${aws_db_instance.db_instance.db_name} -f /tmp/update_parsed.sql"
    ]
  }
}
