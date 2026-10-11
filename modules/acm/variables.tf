variable "domain_name" {
  description = "The domain name for which the ACM certificate will be issued."
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional domain names (SANs) the ACM certificate should cover."
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "The ID of the Route53 hosted zone where the ACM certificate validation record will be created."
  type        = string
}