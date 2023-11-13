variable "auto_scaling_group_name" {
  type        = string
  description = "The name of the auto scaling group"
}

variable "policy_name" {
  type        = string
  description = "The name of the auto scaling policy"
}

variable "adjustment_type" {
  type        = string
  description = "The adjustment type. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity."
}

variable "scaling_adjustment" {
  type        = number
  description = "The number of instances by which to scale. Adjustment must be a positive or negative integer."
}
