variable "alb_listener_name" {
  type        = string
  description = "The name of the load balancer listener"
}

variable "alb_arn" {
  type        = string
  description = "The ARN of the load balancer"
}

variable "alb_target_group_arn" {
  type        = string
  description = "The ARN of the target group"
}
