variable "dns_aliases" {
  description = "A list of DNS aliases (CNAMEs) for the CloudFront distribution."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use for the CloudFront distribution."
  type        = string
}

variable "bucket_arn" {
  description = "The ARN of the S3 bucket that CloudFront will access."
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket (e.g., mybucket.s3.amazonaws.com)."
  type        = string
}