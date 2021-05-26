# launch configurations
resource "aws_launch_configuration" "web_lc" {
  name                 = "web_lc"
  image_id             = var.web_amis[var.region]
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.web.key_name
  user_data            = file("scripts/apache.sh")
  iam_instance_profile = aws_iam_instance_profile.s3_ec2_profile.name
  security_groups      = ["${aws_security_group.web_sg.id}"]
}

# auto scaling group with min and max instances
resource "aws_autoscaling_group" "javahome_asg" {
  name     = "javahome_asg"
  min_size = 1
  max_size = 2

  health_check_grace_period = 60
  health_check_type         = "ELB"
  load_balancers            = ["${aws_elb.javahome_elb.name}"]
  vpc_zone_identifier       = local.pub_sub_ids
  launch_configuration      = aws_launch_configuration.web_lc.name
}

# adding instances when this policy is triggered
resource "aws_autoscaling_policy" "AddInstancesPolicy" {
  name                   = "AddInstancesPolicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.javahome_asg.name
}

# removing instances when this policy is triggered
resource "aws_autoscaling_policy" "RemoveInstancesPolicy" {
  name                   = "RemoveInstancesPolicy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.javahome_asg.name
}


# cpu usage > 80 alarm fires
resource "aws_cloudwatch_metric_alarm" "avg_cpu_ge_80" {
  alarm_name          = "avg_cpu_ge_80"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.javahome_asg.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.AddInstancesPolicy.arn}"]
}

# scaling out removes an instance if its less than 30
resource "aws_cloudwatch_metric_alarm" "avg_cpu_le_30" {
  alarm_name          = "avg_cpu_le_30"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.javahome_asg.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.RemoveInstancesPolicy.arn}"]
}
