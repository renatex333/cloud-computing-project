variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "security_group_name" {
  type        = string
  description = "The name of the security group"
}

variable "port_protocol_cidr" {
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "The list of port, protocol and CIDR blocks to allow ingress traffic from"
}