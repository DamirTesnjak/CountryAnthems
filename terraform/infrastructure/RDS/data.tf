data "aws_ssm_parameter" "postgres_user" {
  name = "postgres_user"
}