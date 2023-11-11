variable "db_subnet_group_name" {
  type        = string
  description = "The name of the subnet group"
}

variable "private_subnet_ids" {
  type        = map(string)
  description = "The IDs of the private subnets"
}