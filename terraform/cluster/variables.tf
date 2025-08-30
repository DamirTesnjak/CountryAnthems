variable "ecr_repository_name_country_anthems_api" {
    description = "The ECR repository name"
    default = "country-anthems-api"
    type = string
}

variable "country_anthems_S3_bucket_name" {
    description = "The S3 bucket name"
    default = "country-anthems-bucket"
    type = string
}