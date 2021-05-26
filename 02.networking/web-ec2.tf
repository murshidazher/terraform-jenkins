locals {
  env_tag = {
    Environment = "${terraform.workspace}" # we need to add env dynamically with a variable
  }

  web_tags = merge(var.web_tags, local.env_tag)
}

resource "aws_instance" "web" {
  count         = var.web_ec2_count # create 2 different instances in 2 zones
  ami           = var.web_amis[var.region]
  instance_type = var.web_instance_type
  subnet_id     = local.pub_sub_ids[count.index]
  tags          = local.web_tags
  user_data     = file("scripts/apache.sh")
}
