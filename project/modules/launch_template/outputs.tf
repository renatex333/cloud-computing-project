output "launch_template_id" {
  value = aws_launch_template.main.id
}

output "dependency" {
  value = [aws_launch_template.main]
}