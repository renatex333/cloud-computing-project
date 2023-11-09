variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "igw_id" {
  type        = string
  description = "The ID of the internet gateway"
}

variable "route_table_name" {
  type        = string
  description = "The name of the route table"
}

variable "cidr_block" {
  type = string
  description = "The CIDR block of the VPC"
}
