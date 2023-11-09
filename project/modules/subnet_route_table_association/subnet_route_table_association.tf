resource "aws_route_table_association" "main" {
  route_table_id = var.route_table_id
  for_each       = var.subnet_ids
  subnet_id      = each.value
}
