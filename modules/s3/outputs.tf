output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_website_url" {
  description = "The URL of the S3 bucket website endpoint"
  value       = var.is_portfolio_website ? aws_s3_bucket_website_configuration.website_configuration[0].website_endpoint : null
}

output "bucket_hosted_zone_id" {
  description = "The hosted zone ID for the S3 bucket"
  value       = aws_s3_bucket.bucket.hosted_zone_id
}

output "bucket_regional_domain_name" {
  description = "The regional domain name for the S3 bucket"
  value       = aws_s3_bucket.bucket.bucket_regional_domain_name
}
