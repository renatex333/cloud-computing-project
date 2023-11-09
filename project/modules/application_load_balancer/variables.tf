variable "alb_name" {
  type        = string
  description = "Name of the ALB"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to assign to the ALB"
}

variable "subnet_ids" {
  type        = map(string)
  description = "List of subnet IDs to assign to the ALB"
}