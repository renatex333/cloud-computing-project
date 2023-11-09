resource "aws_autoscaling_group" "main" {
  name                      = var.auto_scaling_group_name
  max_size                  = 5
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = var.public_subnet_ids
  placement_group           = var.placement_group_id
  
  launch_template {
    id = var.launch_template_id
  }

  target_group_arns = var.target_group_arns
}