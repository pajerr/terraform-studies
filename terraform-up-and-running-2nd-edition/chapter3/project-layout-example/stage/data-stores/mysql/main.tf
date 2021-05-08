provider "aws" {
  region = "us-east-2"
}


terraform {
  backend "s3" {
    key            = "stage/data-stores/mysql/terraform.tfstate"
  }
}


resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"

  username            = var.db_username
  name                = var.db_name
  password            = var.db_password
}