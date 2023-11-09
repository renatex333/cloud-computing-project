output "security_group_id" {
  value       = aws_security_group.main.id
  description = "The ID of the security group"
  sensitive   = true
}