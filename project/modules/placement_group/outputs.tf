output "placement_group_id" {
  value = aws_placement_group.main.id
  description = "The ID of the placement group"
  sensitive = true
}