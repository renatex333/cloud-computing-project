variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "security_group_name" {
  type        = string
  description = "The name of the security group"
}

variable "security_group_ingress_cidr_blocks" {
  type        = list(string)
  description = "The list of CIDR blocks to allow ingress traffic from"
} 
