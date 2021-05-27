resource "aws_db_instance" "javahome" {
  identifier                 = "javahome-${terraform.workspace}"
  allocated_storage          = 20 # default
  storage_type               = "gp2"
  engine                     = "mysql"
  engine_version             = "5.7"
  instance_class             = "db.t2.micro"
  name                       = "javahome"
  username                   = "javahome"
  password                   = "Admin4321"
  parameter_group_name       = "default.mysql5.7"
  db_subnet_group_name       = aws_db_subnet_group.javahome.id
  backup_window              = "01:00-01:30"
  auto_minor_version_upgrade = false
}

resource "aws_db_subnet_group" "javahome" {
  name       = "javahome-rds"
  subnet_ids = aws_subnet.private.*.id

  tags = {
    Name = "Javahome RDS Subnet Group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow traffic for rds "
  vpc_id      = aws_vpc.my_app.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
