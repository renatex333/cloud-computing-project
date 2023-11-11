output "alb_arn" {
  value = aws_lb.main.arn
  description = "The ARN of the load balancer"
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
  description = "The DNS name of the load balancer"
}