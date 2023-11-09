variable "vpc_id" {
  type        = string
  description = "The VPC ID to attach the internet gateway to"
}

variable "igw_name" {
  type        = string
  description = "The name of the internet gateway"
}
