output "db_subnet_group_name" {
  value = aws_db_subnet_group.main.name
  description = "The name of the subnet group"
}