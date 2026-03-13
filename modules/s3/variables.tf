variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
}

variable "is_public" {
  description = "Whether the S3 bucket should be public or not"
  type        = bool
  default     = false
}

variable "is_portfolio_website" {
  description = "Whether the S3 bucket should be configured as a portfolio website or not"
  type        = bool
  default     = false
}

variable "auto_upload_documents" {
  description = "Whether to automatically upload the website documents (index.html and error.html) to the S3 bucket"
  type        = bool
  default     = false
}

variable "website_documents_path" {
  description = "The local path to the website documents (index.html and error.html)"
  type        = string
  default     = "./documents"
}

variable "is_cloudfront_origin" {
  description = "Whether the S3 bucket will be used as an origin for a CloudFront distribution"
  type        = bool
  default     = false
}

variable "cloudfront_bucket_policy_json" {
  description = "The IAM policy document for the CloudFront access to the S3 bucket"
  type        = any
}