resource "aws_autoscaling_policy" "main" {
  autoscaling_group_name = var.auto_scaling_group_name
  name                   = var.policy_name
  policy_type            = "SimpleScaling"
  adjustment_type        = var.adjustment_type
  scaling_adjustment     = var.scaling_adjustment
}
