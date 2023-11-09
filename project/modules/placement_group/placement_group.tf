resource "aws_placement_group" "main" {
  name     = var.placement_group_name
  strategy = "spread"
}