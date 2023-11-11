resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = values(var.private_subnet_ids)

  tags = {
    Name = var.db_subnet_group_name
  }
}