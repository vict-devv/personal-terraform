variable "domain_name" {
  description = "The domain name for the Route53 hosted zone."
  type        = string
}

variable "record_alias_name" {
  description = "The alias target for the A record (e.g., CloudFront distribution domain name)."
  type        = string
}

variable "record_alias_zone_id" {
  description = "The hosted zone ID for the alias target (e.g., CloudFront distribution hosted zone ID)."
  type        = string
}