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
