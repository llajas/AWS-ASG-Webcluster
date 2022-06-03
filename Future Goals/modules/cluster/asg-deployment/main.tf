terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#Search for latest AWS AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

#Webserver installation, configuration code & launch (root & secondary drives) 
resource "aws_launch_configuration" "webserver-launch-config" {
  name_prefix   = "webserver-launch-config"
  image_id      =  data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name = var.keyname
  security_groups = ["${aws_security_group.webserver_securitygroup.id}"]
  
  root_block_device {
            volume_type = "gp2"
            volume_size = 10
            encrypted   = true
        }
  ebs_block_device {
            device_name = "/dev/sdf"
            volume_type = "gp2"
            volume_size = 5
            encrypted   = true
        }
lifecycle {
        create_before_destroy = true
     }
  user_data = filebase64("${path.module}/init_webserver.sh")
}

#Create Auto Scaling Group
resource "aws_autoscaling_group" "asg_example" {
  name       = "asg_example"
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  force_delete       = true
  depends_on         = [aws_lb.app_lb]
  target_group_arns  =  ["${aws_lb_target_group.target_group.arn}"]
  health_check_type  = "EC2"
  launch_configuration = aws_launch_configuration.webserver-launch-config.name
  vpc_zone_identifier = ["${aws_subnet.private_subnet1.id}","${aws_subnet.private_subnet2.id}"]
  
 tag {
       key                 = "Name"
       value               = "asg_example"
       propagate_at_launch = true
    }
}

#Scale accordingly per the Cloudwatch CPU Metric below
resource "aws_autoscaling_policy" "asp" {
  name                   = "${var.cluster_name}-autoscaling"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_example.name
}

#Monitor for high CPU usage
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name  = "${var.cluster_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_example.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.asp.arn]
}

