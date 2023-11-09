resource "aws_lb_target_group" "main" {
  name        = var.alb_target_group_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
  }

  tags = {
    Name = var.alb_target_group_name
  }
}