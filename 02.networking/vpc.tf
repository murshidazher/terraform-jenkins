resource "aws_vpc" "my_app" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name        = "JavahomeVpc"
    Environment = "${terraform.workspace}"
  }
}
