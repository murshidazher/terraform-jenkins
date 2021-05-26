resource "aws_subnet" "private" {
  count             = length(slice(local.az_names, 0, 2))
  vpc_id            = aws_vpc.my_app.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(local.az_names))
  availability_zone = local.az_names[count.index]
  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}

# NAT instances
resource "aws_instance" "nat" {
  ami               = var.nat_amis[var.region]
  instance_type     = "t2.micro"
  subnet_id         = local.pub_sub_ids[0]
  source_dest_check = false
  # associate_public_ip_address = true # we dont need this since we auto-assigned ip address
  vpc_security_group_ids = ["${aws_security_group.nat_sg.id}"]
  tags = {
    Name = "JavahomeNat"
  }
}
