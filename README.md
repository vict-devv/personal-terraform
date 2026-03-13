# Personal Portfolio Infrastructure

Terraform project that provisions a secure static portfolio stack on AWS using S3 + CloudFront + Route53 + ACM.

The website content is stored in S3, served through CloudFront, and exposed over HTTPS with an ACM certificate.

## Features

- HTTPS-enabled delivery through CloudFront
- Private S3 bucket used as CloudFront origin (not public website hosting)
- Origin Access Control (OAC) policy between CloudFront and S3
- Automatic upload of portfolio assets (`index.html`, `error.html`, and favicon)
- Route53 hosted zone and DNS alias to CloudFront
- ACM certificate with DNS validation in `us-east-1` (required for CloudFront)
- Remote Terraform state stored in S3 backend

## Architecture

```
Internet User
      |
      v
Route53 (A alias: www.domain)
      |
      v
CloudFront Distribution (HTTPS, redirect HTTP -> HTTPS)
      |
      v
S3 Bucket (private origin)
```

## Project Structure

```
personal-terraform/
├── backend.tf
├── main.tf
├── providers.tf
├── terraform.tfvars
├── variables.tf
├── modules/
│   ├── acm/
│   ├── cloudfront/
│   ├── route53/
│   └── s3/
└── portfolio/
      ├── favicon/
      │   └── favicon.png
      └── pages/
            ├── error.html
            └── index.html
```

## Modules

### `s3`

- Creates the content bucket (`www.<domain>`)
- Uploads portfolio assets when enabled
- Keeps bucket private for CloudFront origin mode
- Applies CloudFront-origin bucket policy when provided

Key options currently used:
- `is_public = false`
- `is_portfolio_website = false`
- `is_cloudfront_origin = true`
- `auto_upload_documents = true`

### `cloudfront`

- Creates the CloudFront distribution with S3 origin
- Configures OAC for signed access to S3
- Forces HTTPS via `viewer_protocol_policy = "redirect-to-https"`
- Uses custom ACM certificate

Key outputs:
- Distribution domain name
- Distribution hosted zone ID
- Generated S3 bucket policy JSON for CloudFront access

### `acm`

- Requests certificate for `*.${domain_name}`
- Validates certificate via Route53 DNS records
- Uses AWS provider alias in `us-east-1`

### `route53`

- Creates hosted zone for root domain
- Creates `www.<domain>` alias record to CloudFront

## Prerequisites

- Terraform `~> 1.14`
- AWS provider `~> 6.0`
- AWS credentials with permissions for S3, CloudFront, Route53, ACM, and IAM policy updates
- Domain that can use the Route53 name servers created by this project

## Configuration

Root variables:

| Variable | Description | Default | Required |
|---|---|---|---|
| `domain_name` | Root domain used for Route53 and `www` alias | none | Yes |
| `aws_region` | Primary deployment region (S3/Route53) | `ca-central-1` | No |

Example `terraform.tfvars`:

```hcl
domain_name = "vict-devv.com"
```

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

After apply:
- Update your registrar name servers with Route53 output values (if not already delegated)
- Wait for DNS and ACM validation to finish
- Visit `https://www.<your-domain>`

## Content Updates

Update files under `portfolio/` and run:

```bash
terraform apply
```

Terraform updates S3 objects using `etag = filemd5(...)`, so changed files are uploaded automatically.

## Backend State

Terraform state is configured in S3 backend:

```hcl
backend "s3" {
   bucket       = "victor-devops-tfstate-bucket"
   key          = "personal/terraform.tfstate"
   region       = "ca-central-1"
   use_lockfile = true
   encrypt      = true
}
```

Ensure the backend bucket already exists before `terraform init`.

## Troubleshooting

### HTTPS certificate not issued yet

- Check ACM certificate status in `us-east-1`
- Confirm DNS validation records exist in Route53
- Allow propagation time

### Site returns AccessDenied

- Confirm S3 bucket is private (`is_public = false`)
- Confirm CloudFront OAC policy is applied to the bucket
- Re-run `terraform apply` to reconcile policy drift

### Domain not resolving to CloudFront

- Verify Route53 NS delegation at your registrar
- Confirm `www` alias record targets CloudFront domain

## Destroy

```bash
terraform destroy
```

## Useful References

- Terraform AWS Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- CloudFront with S3 origin and OAC: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
- ACM for CloudFront (us-east-1): https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html
