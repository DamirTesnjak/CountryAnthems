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
  allocated_storage                   = 20
  db_name                             = "geo"
  engine                              = "postgres"
  engine_version                      = "17.6"
  iam_database_authentication_enabled = false
  instance_class                      = "db.t4g.micro"
  username                            = var.db_user
  password                            = random_string.password.result
  parameter_group_name                = "default.postgres17"
  db_subnet_group_name                = aws_db_subnet_group.rds-subnets.name
  publicly_accessible                 = false
  skip_final_snapshot                 = true
  vpc_security_group_ids              = [var.security_group_db_id]
  port = 5432
}

resource "null_resource" "enable_postgis" {
  triggers = {
    bastion_id = var.aws_instance_bastion_id
  }
  depends_on = [aws_db_instance.this]

  connection {
    type        = "ssh"
    host        = var.bastion_public_ip
    user        = "ubuntu"
    private_key = var.bastion_private_key
  }

  provisioner "remote-exec" {

    inline = [
       "sudo apt-get update",
       "sudo apt-get install -y postgresql-client",
      "PGPASSWORD='${random_string.password.result}' psql -h ${aws_db_instance.this.address} -p ${aws_db_instance.this.port} -U ${var.db_user} -d ${aws_db_instance.this.db_name} -c \"CREATE EXTENSION IF NOT EXISTS postgis;\""
    ]
  }
}

resource "null_resource" "seed_db" {
  triggers = {
    bastion_id = var.aws_instance_bastion_id
  }
  depends_on = [null_resource.enable_postgis]

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

  provisioner "remote-exec" {
    inline = [
      "PGPASSWORD='${random_string.password.result}' psql -h ${aws_db_instance.this.address} -p ${aws_db_instance.this.port} -U ${var.db_user} -d ${aws_db_instance.this.db_name} --file=/tmp/init.sql"
    ]
  }
}

resource "null_resource" "import_geojson" {
  triggers = {
    bastion_id = var.aws_instance_bastion_id
  }
  depends_on = [null_resource.seed_db]

  connection {
    type        = "ssh"
    host        = var.bastion_public_ip
    user        = "ubuntu"
    private_key = var.bastion_private_key
  }

  provisioner "file" {
    source      = "${path.module}/migrations/02_import.sh"
    destination = "/tmp/import.sh"
  }

   provisioner "file" {
    source      = "${path.module}/migrations/countries.geojson"
    destination = "/tmp/countries.geojson"
  }


  provisioner "remote-exec" {
    inline = [
      "sed -i 's/\r$//' /tmp/import.sh",
      "sudo apt-get update",
      "sudo apt-get install gdal-bin",
      "sudo apt install dos2unix",
      "dos2unix /tmp/import.sh",
      "chmod +x /tmp/import.sh",
      "echo 'export PGHOST=${aws_db_instance.this.address}' >> ~/.bashrc",
      "echo 'export PGPORT=${aws_db_instance.this.port}' >> ~/.bashrc",
      "echo 'export POSTGRES_USER=${var.db_user}' >> ~/.bashrc",
      "echo 'export POSTGRES_PASSWORD=${random_string.password.result}' >> ~/.bashrc",
      "echo 'export POSTGRES_DB=${aws_db_instance.this.db_name}' >> ~/.bashrc",
      "/tmp/import.sh"
    ]
  }
}

resource "null_resource" "populate_with_data" {
  triggers = {
    bastion_id = var.aws_instance_bastion_id
    data_path  = "${path.module}/migrations/countries_capitals_anthems.json"
    sql_file   = "${path.module}/migrations/update.sql"
  }

  depends_on = [null_resource.import_geojson]

  connection {
    type        = "ssh"
    host        = var.bastion_public_ip
    user        = "ubuntu"
    private_key = var.bastion_private_key
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
      "sed \"s|__DATA_PATH__|/tmp/countries_capitals_anthems.json|g\" /tmp/update.sql > /tmp/update_parsed.sql",
      "PGPASSWORD='${random_string.password.result}' psql -h ${aws_db_instance.this.address} -p ${aws_db_instance.this.port} -U ${var.db_user} -d ${aws_db_instance.this.db_name} -f /tmp/update.sql"
    ]
  }
}
