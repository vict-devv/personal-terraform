output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.bucket.bucket
}

output "bucket_website_url" {
  description = "The URL of the S3 bucket website endpoint"
  value       = aws_s3_bucket_website_configuration.website_configuration[0].website_endpoint
}

output "bucket_hosted_zone_id" {
  description = "The hosted zone ID for the S3 bucket"
  value       = aws_s3_bucket.bucket.hosted_zone_id
}
