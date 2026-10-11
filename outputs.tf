output "route53_name_servers" {
  description = "The name servers for the Route53 hosted zone. These must match the NS records at the domain registrar."
  value       = module.route53.name_servers
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = module.cloudfront.distribution_domain_name
}
