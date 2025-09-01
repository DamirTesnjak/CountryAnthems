provider "aws" {
    region = "us-west-2"
}

module infrastructure {
    source = "./infrastructure"

    name = "country-anthems"
    db_port = 5432
    ecs_port = 8080
}