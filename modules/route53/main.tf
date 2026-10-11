resource "aws_route53_zone" "main" {
  name    = var.domain_name
  comment = "Hosted Zone Managed by Terraform"

  # Recreating the zone assigns new name servers, which breaks DNS until the
  # registrar is updated. Remove this block deliberately if the zone must go.
  lifecycle {
    prevent_destroy = true
  }
}

locals {
  # Both the apex and www point at the same alias target, over IPv4 (A) and IPv6 (AAAA).
  alias_records = {
    for pair in setproduct(["apex", "www"], ["A", "AAAA"]) : "${pair[0]}_${pair[1]}" => {
      name = pair[0] == "apex" ? var.domain_name : "www.${var.domain_name}"
      type = pair[1]
    }
  }
}

resource "aws_route53_record" "alias" {
  for_each = local.alias_records

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type

  alias {
    name                   = var.record_alias_name
    zone_id                = var.record_alias_zone_id
    evaluate_target_health = false
  }
}

moved {
  from = aws_route53_record.www
  to   = aws_route53_record.alias["www_A"]
}
