resource "aws_route53_zone" "main" {
  name    = var.domain_name
  comment = "Hosted Zone Managed by Terraform"

  # Recreating the zone assigns new name servers, which breaks DNS until the
  # registrar is updated. Remove this block deliberately if the zone must go.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.record_alias_name
    zone_id                = var.record_alias_zone_id
    evaluate_target_health = false
  }
}
