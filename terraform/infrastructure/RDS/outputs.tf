output "database_host" {
    value = aws_db_instance.db_instance.address
}

output "database_password" {
    value = aws_db_instance.db_instance.password
}

output "database_name" {
    value = aws_db_instance.db_instance.db_name
}