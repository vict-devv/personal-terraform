output "distribution_hosted_zone_id" {
  description = "The hosted zone ID for the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.hosted_zone_id
}

output "distribution_domain_name" {
  description = "The domain name for the CloudFront distribution"
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "s3_bucket_policy" {
  description = "The IAM policy document for the CloudFront access to the S3 bucket"
  value       = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}