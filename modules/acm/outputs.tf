output "cert_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.cert.arn
}

output "validated_cert_arn" {
  description = "The ARN of the ACM certificate, available only once DNS validation has completed"
  value       = aws_acm_certificate_validation.cert.certificate_arn
}
