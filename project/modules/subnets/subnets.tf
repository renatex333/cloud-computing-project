resource "aws_subnet" "main" {
  vpc_id                  = var.vpc_id
  for_each                = var.subnet_infos
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip

  tags = {
    Name = each.value.name
  }
}
