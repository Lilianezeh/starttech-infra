variable "project_name" { default = "starttech" }
variable "asg_name"     {}
variable "alb_arn"      {}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/starttech/backend"
  retention_in_days = 7
  tags              = { Name = "${var.project_name}-backend-logs" }
}

resource "aws_cloudwatch_log_group" "infrastructure" {
  name              = "/starttech/infrastructure"
  retention_in_days = 7
  tags              = { Name = "${var.project_name}-infra-logs" }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU utilization is too high"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

output "backend_log_group"        { value = aws_cloudwatch_log_group.backend.name }
output "infrastructure_log_group" { value = aws_cloudwatch_log_group.infrastructure.name }