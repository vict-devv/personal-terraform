output "name_servers" {
  description = "The name servers for the Route53 hosted zone. May need to be added to your domain registrar's settings."
  value       = aws_route53_zone.main.name_servers
}
