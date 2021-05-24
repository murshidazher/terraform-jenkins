provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "javahome-tf-1234567" # create the s3 bucket manually
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name        = "JavaHomeVPC"
    Environment = "Dev"
  }
}

output "vpc_cidr" {
  value = aws_vpc.my_vpc.cidr_block
}
