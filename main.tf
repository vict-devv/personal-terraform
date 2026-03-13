module "s3" {
  source                        = "./modules/s3"
  bucket_name                   = "www.${var.domain_name}"
  is_public                     = false
  auto_upload_documents         = true
  is_portfolio_website          = false
  is_cloudfront_origin          = true
  cloudfront_bucket_policy_json = module.cloudfront.s3_bucket_policy
  website_documents_path        = "./portfolio"
}

module "acm" {
  source          = "./modules/acm"
  domain_name     = "*.${var.domain_name}"
  route53_zone_id = module.route53.zone_id
}

module "cloudfront" {
  source                      = "./modules/cloudfront"
  bucket_arn                  = module.s3.bucket_arn
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  acm_certificate_arn         = module.acm.cert_arn
  dns_aliases                 = ["www.${var.domain_name}"]
}

module "route53" {
  source               = "./modules/route53"
  domain_name          = var.domain_name
  record_alias_name    = module.cloudfront.distribution_domain_name
  record_alias_zone_id = module.cloudfront.distribution_hosted_zone_id
}
