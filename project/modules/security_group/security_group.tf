resource "aws_security_group" "main" {
  name   = var.security_group_name
  vpc_id = var.vpc_id

  ingress {
    description = "Allow all requests on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = var.security_group_ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}
