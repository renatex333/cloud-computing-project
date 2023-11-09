variable "launch_template_name" {
  type        = string
  description = "The name of the launch template"
}

variable "security_group_ids" {
  type        = list(string)
  description = "The IDs of the security groups"
}

variable "availability_zone" {
  type        = string
  description = "The availability zone"
}

variable "image_id" {
  type        = string
  description = "The ID of the image"
}