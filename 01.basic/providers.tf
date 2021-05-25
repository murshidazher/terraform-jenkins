provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "javahome-tf-1234567" # create the s3 bucket manually
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "javahome-tf"
  }
}

resource "aws_vpc" "my_vpc" {
  count            = terraform.workspace == "dev" ? 0 : 1
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name        = "JavaHomeVPC"
    Environment = "${terraform.workspace}"
    Location    = "India"
  }
}

output "vpc_cidr" {
  value = aws_vpc.my_vpc.cidr_block
}
