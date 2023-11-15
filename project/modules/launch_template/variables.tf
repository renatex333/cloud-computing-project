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

variable "hostname" {
  type        = string
  description = "The hostname of the database"
}

variable "username" {
  type        = string
  description = "The username of the database"
}

variable "password" {
  type        = string
  description = "The password of the database"
}