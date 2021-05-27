resource "aws_db_instance" "javahome" {
  identifier           = "javahome-${terraform.workspace}"
  allocated_storage    = 20 # default
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "javahome"
  username             = "javahome"
  password             = "Admin4321"
  parameter_group_name = "default.mysql5.7"
}
