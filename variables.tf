variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ca-central-1"
}

variable "domain_name" {
    description = "The domain name for the Route53 hosted zone."
    type        = string
}