provider "aws" {
  region = "us-east-1"  # Update with your desired region
}

resource "aws_launch_configuration" "example" {
  name = "example"
  image_id = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS
  instance_type = "t2.micro"  # Update with your desired instance type

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
              #!/bin/bash
              # Your user data script goes here
            EOF
}

resource "aws_autoscaling_group" "example" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  health_check_type    = "EC2"
  health_check_grace_period = 300  # 300 seconds (5 minutes)

  force_delete = true  # Allow Terraform to delete ASG without waiting for instances to terminate

  vpc_zone_identifier = ["subnet-xxxxxxxxxx"]  # Update with your subnet ID

  launch_configuration = aws_launch_configuration.example.id

  tag {
    key                 = "Name"
    value               = "example"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"



  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "high_cpu_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 300 seconds (5 minutes)
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Scale Up when CPU exceeds 75% for 5 minutes"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "low_cpu_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 300 seconds (5 minutes)
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "Scale Down when CPU is below 50% for 5 minutes"
}

# The following data "aws_lambda_function" is for the daily refresh task.
data "aws_lambda_function" "refresh_function" {
  function_name = "your_lambda_function_name"  # Replace with your Lambda function name
}

# Schedule the daily refresh using CloudWatch Events
resource "aws_cloudwatch_event_rule" "daily_refresh" {
  name        = "daily_refresh"
  description = "Schedule daily refresh at UTC 12am"
  schedule_expression = "cron(0 0 * * ? *)"  # UTC 12am every day

}
