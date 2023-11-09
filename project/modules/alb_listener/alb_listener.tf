resource "aws_lb_listener" "main" {
  load_balancer_arn = var.alb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.alb_target_group_arn
  }

  tags = {
    Name = var.alb_listener_name
  }
}