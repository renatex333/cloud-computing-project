variable "auto_scaling_group_name" {
  type        = string
  description = "The name of the auto scaling group"
}

variable "launch_template_id" {
  type        = string
  description = "The ID of the launch template"
}

variable "target_group_arns" {
  type        = list(string)
  description = "The ARNs of the target groups"
}

variable "placement_group_id" {
  type        = string
  description = "The ID of the placement group"
}

variable "public_subnet_ids" {
  type        = map(string)
  description = "The IDs of the public subnets"
}