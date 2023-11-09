output "alb_target_group_arn" {
  value = aws_lb_target_group.main.arn
  description = "The ARN of the load balancer target group"
}