output "alb_dns_name" {
  value       = module.staging_webserver.alb_dns_name
  description = "The domain name of the load balancer"
}
