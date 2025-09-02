resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    
    tags = {
        Name = "main"
    }
}

module "securityGroup" {
    source = "./securityGroup"
    
    vpc_id = aws_vpc.main.id
    db_port = var.db_port
    ecs_port = var.ecs_port
}