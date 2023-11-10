resource "aws_launch_template" "main" {
  name = var.launch_template_name

  image_id = var.image_id

  instance_type = "t2.micro"

  monitoring {
    enabled = true
  }

  placement {
    availability_zone = var.availability_zone
  }

  vpc_security_group_ids = var.security_group_ids

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.launch_template_name
    }
  }

  user_data = filebase64("${path.module}/script.sh")
}
