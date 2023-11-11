variable "db_allocated_storage" {
  type        = number
  description = "The allocated storage in gibibytes"
}

variable "db_max_allocated_storage" {
  type        = number
  description = "The maximum allocated storage in gibibytes"
}

variable "db_name" {
  type        = string
  description = "The name of the database to create"
}

variable "db_engine" {
  type        = string
  description = "The database engine to use"
}

variable "db_engine_version" {
  type        = string
  description = "The engine version to use"
}

variable "db_subnet_group_name" {
  type        = string
  description = "The name of the subnet group"
}

variable "db_security_group_ids" {
  type        = list(string)
  description = "The security group ids to use"
}
