output "pg_host" {
    value = aws_db_instance.this.address
}

output "pg_password" {
    value = aws_db_instance.this.password
}

output "pg_db" {
    value = aws_db_instance.this.db_name
}