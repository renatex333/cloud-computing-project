output "alb_arn" {
  value = aws_lb.main.arn
  description = "The ARN of the load balancer"
  sensitive = true
}