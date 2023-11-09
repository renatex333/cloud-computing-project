resource "aws_route_table" "main" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.cidr_block
    gateway_id = var.igw_id
  }

  tags = {
    Name = var.route_table_name
  }
}
