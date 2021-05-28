# 1. create a target group
resource "aws_lb_target_group" "javahome" {
  name     = "javahome-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.my_app.id}"
}

resource "aws_lb_target_group_attachment" "javahome" {
  count            = "${var.web_ec2_count}"
  target_group_arn = "${aws_lb_target_group.javahome.arn}"
  target_id        = "${aws_instance.web.*.id[count.index]}"
  port             = 80
}

resource "aws_lb" "javahome" {
  name               = "javahome-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.elb_sg.id}"]
  subnets            = "${local.pub_sub_ids}"
  access_logs {
    bucket  = "javahome-alb-access-logs"
    enabled = true
  }
  tags = {
    Environment = "${terraform.workspace}"
  }
}


# forward the request which comes to port number 80 to target group
resource "aws_lb_listener" "web_tg" {
  load_balancer_arn = "${aws_lb.javahome.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.javahome.arn}"
  }
}

data "template_file" "javahome" {
  template = "${file("scripts/iam/alb-s3-access-logs.json")}"
  vars = {
    access_logs_bucket = "javahome-alb-access-logs"
  }
}
