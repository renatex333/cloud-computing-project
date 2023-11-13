resource "aws_cloudwatch_metric_alarm" "main" {
  alarm_name                = var.alarm_name
  namespace                 = var.namespace
  metric_name               = var.metric_name
  statistic                 = "Average"
  period                    = 300
  comparison_operator       = var.comparison_operator
  threshold                 = var.threshold
  evaluation_periods        = 1
  alarm_description         = "This metric monitors the auto-scaling group cpu utilization"
  insufficient_data_actions = []
  alarm_actions             = [var.autoscaling_policy_arn]
}