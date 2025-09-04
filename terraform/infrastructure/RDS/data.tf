data "aws_ssm_parameter" "postgres_user" {
  name  = "POSTGRES_USER"
}