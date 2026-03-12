module "s3" {
  source                 = "./modules/s3"
  bucket_name            = "www.vict-devv.com"
  is_public              = true
  auto_upload_documents  = true
  is_portfolio_website   = true
  website_documents_path = "./portfolio"
}

module "route53" {
  source               = "./modules/route53"
  domain_name          = var.domain_name
  record_alias_name    = "s3-website.${var.aws_region}.amazonaws.com"
  record_alias_zone_id = module.s3.bucket_hosted_zone_id
}
