output "database_host" {
    value = aws_db_instance.this.address
}

output "database_password" {
    value = aws_db_instance.this.password
}

output "database_name" {
    value = aws_db_instance.this.db_name
}