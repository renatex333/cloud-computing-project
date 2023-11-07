variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "subnet_infos" {
  type = map(object({
    name              = string
    availability_zone = string
    cidr_block        = string
    map_public_ip     = bool
  }))
  description = "Important information about the subnet. Name, availability zone, CIDR block, and whether a public IP should be mapped on launch."
}
