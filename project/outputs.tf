output "Application_URL" {
  value = "http://${module.alb.alb_dns_name}"
}