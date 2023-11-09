variable "route_table_id" {
  type        = string
  description = "The ID of the route table"
}

variable "subnet_ids" {
  type        = set(string)
  description = "The IDs of the subnets"
}