module "my_vpc" {
  source = "../modules/vpc"

  vpc_cidr    = "192.168.0.0/16"
  tenancy     = "default"
  vpc_id      = module.vpc.vpc_id #output variable
  subnet_cidr = "192.168.1.0/24"
}

module "my_ec2" {
  source = "../modules/ec2"

}
