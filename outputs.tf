output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution serving the portfolio. Used by CI to invalidate the cache after a deploy."
  value       = module.cloudfront.distribution_id
}

output "route53_name_servers" {
  description = "The name servers for the Route53 hosted zone, to set at the domain registrar."
  value       = module.route53.name_servers
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = module.cloudfront.distribution_domain_name
}