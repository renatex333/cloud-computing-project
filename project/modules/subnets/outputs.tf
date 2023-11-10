output "public_subnet_ids" {
  value = { for k, subnet in aws_subnet.main : k => subnet.id if var.subnet_infos[k].map_public_ip }
  description = "The IDs of the public subnets"
}

output "private_subnet_ids" {
  value = { for k, subnet in aws_subnet.main : k => subnet.id if !var.subnet_infos[k].map_public_ip }
  description = "The IDs of the private subnets"
}