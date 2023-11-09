output "public_subnet_ids" {
  value       = [for k, v in aws_subnet.main : aws_subnet.main[k].id if var.subnet_infos[k].map_public_ip == true]
  description = "The IDs of the public subnets"
  sensitive   = true
}