# 🌐 Personal Portfolio Infrastructure

A modern, Infrastructure-as-Code solution for deploying a personal portfolio website on AWS using Terraform. This project provisions and manages cloud resources including S3 static hosting, Route53 DNS, and automated content deployment.

## ✨ Features

- **🪣 S3 Static Website Hosting** - Fast, scalable, and cost-effective static website hosting
- **🔗 Route53 DNS Management** - Automated DNS records pointing to your S3 website
- **📝 Infrastructure as Code** - Fully reproducible infrastructure using Terraform
- **🤖 Auto-Upload Documents** - Automatically synchronize portfolio content to S3
- **🔐 Secure Backend** - Terraform state stored encrypted in S3
- **📦 Modular Architecture** - Reusable, well-organized Terraform modules
- **🌍 Multi-Region Support** - Easily deployable to different AWS regions

## 📁 Project Structure

```
personal-terraform/
├── main.tf                 # Root module configuration
├── variables.tf            # Input variables
├── providers.tf            # AWS provider configuration
├── terraform.tfvars        # Variable values
├── backend.tf              # Terraform state configuration
│
├── modules/
│   ├── s3/
│   │   ├── main.tf         # S3 bucket and website configuration
│   │   ├── variables.tf    # S3 module variables
│   │   └── outputs.tf      # S3 module outputs
│   │
│   └── route53/
│       ├── main.tf         # Route53 hosted zone and records
│       ├── variables.tf    # Route53 module variables
│       └── outputs.tf      # Route53 module outputs
│
└── portfolio/
    └── pages/
        ├── index.html      # Homepage
        └── error.html      # Error page (404, etc.)
```

## 🚀 Quick Start

### Prerequisites

- **Terraform** ~> 1.14
- **AWS CLI** configured with appropriate credentials
- **AWS Account** with permissions to create S3 buckets, Route53 zones, and other resources

### Installation & Deployment

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd personal-terraform
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Review the plan**
   ```bash
   terraform plan
   ```

4. **Apply the configuration**
   ```bash
   terraform apply
   ```

5. **Verify deployment**
   - Check Route53 hosted zone in AWS Console
   - Verify S3 bucket is created and website is accessible
   - Test your domain is resolving correctly

## 🔧 Configuration

### Variables

Key variables you can customize:

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `domain_name` | Your domain name for Route53 | - | ✅ Yes |
| `aws_region` | AWS region for resource deployment | `ca-central-1` | ❌ No |

### Customization

Edit `terraform.tfvars` to customize your deployment:

```hcl
domain_name = "your-domain.com"
aws_region  = "us-east-1"  # or your preferred region
```

### S3 Module Configuration

The S3 module supports several options:
- `bucket_name` - Name of your S3 bucket
- `is_public` - Make bucket publicly accessible (default: `false`)
- `is_portfolio_website` - Enable website configuration (default: `false`)
- `auto_upload_documents` - Auto-sync portfolio files (default: `false`)
- `website_documents_path` - Path to portfolio files (default: `./portfolio`)

## 📊 Architecture

```
┌─────────────────────────────────────────────────┐
│              Your Domain (Route53)              │
│           vict-devv.com / www.vict-devv.com    │
└────────────────┬────────────────────────────────┘
                 │ A Record (Alias)
                 ▼
        ┌────────────────────┐
        │  Route53 Hosted    │
        │  Zone              │
        └────────┬───────────┘
                 │ Alias Target
                 ▼
        ┌────────────────────────┐
        │  S3 Bucket             │
        │  Static Website        │
        │  (index.html, etc.)    │
        └────────────────────────┘
```

## 🔐 Security & Best Practices

✅ **Implemented:**
- S3 public access block management
- Encrypted Terraform state storage
- IAM bucket policy for public website access
- Error page handling (404 redirects)

📋 **Recommendations:**
- Use AWS Secrets Manager for sensitive data
- Enable S3 versioning for content backup
- Consider CloudFront CDN for global distribution
- Implement AWS WAF for additional protection
- Enable access logging for audit trails

## 🛠️ Terraform Backend Setup

This project uses an S3 backend to store Terraform state securely:

```hcl
bucket  = "victor-devops-tfstate-bucket"
key     = "personal/terraform.tfstate"
region  = "ca-central-1"
encrypt = true
```

**Note:** The backend bucket must exist before running `terraform init`. Create it with:
```bash
aws s3 mb s3://victor-devops-tfstate-bucket --region ca-central-1
aws s3api put-bucket-versioning \
  --bucket victor-devops-tfstate-bucket \
  --versioning-configuration Status=Enabled
```

## 📚 Modules

### S3 Module
Manages S3 bucket configuration for static website hosting:
- Creates versioning-enabled bucket
- Configures public access policies
- Sets up website configuration (index & error docs)
- Auto-uploads portfolio content

**Outputs:**
- `bucket_id` - S3 bucket identifier
- `bucket_name` - S3 bucket name
- `bucket_hosted_zone_id` - Hosted zone ID for Route53 alias

### Route53 Module
Manages DNS configuration:
- Creates hosted zone for your domain
- Sets up A record pointing to S3 website
- Supports www subdomain alias

**Outputs:**
- `zone_id` - Route53 hosted zone ID
- `nameservers` - Route53 nameservers (for domain registrar)

## 💡 Usage Examples

### Deploy to a Different AWS Region
```bash
terraform apply -var="aws_region=us-west-2"
```

### Update Portfolio Content
Simply update files in `portfolio/pages/` and reapply:
```bash
terraform apply
```

The S3 module will automatically sync changes.

### Remove All Resources
```bash
terraform destroy
```

## 📝 Outputs

After deployment, key information will be displayed:

```
s3_bucket_name = "www.vict-devv.com"
s3_website_url = "http://www.vict-devv.com.s3-website.ca-central-1.amazonaws.com"
route53_zone_id = "Z1234567890ABC"
```

## 🔄 CI/CD Integration

This infrastructure can be integrated with CI/CD pipelines (GitHub Actions, GitLab CI, etc.):

```yaml
- name: Deploy Infrastructure
  run: |
    terraform init
    terraform plan -out=tfplan
    terraform apply tfplan
```

## 🐛 Troubleshooting

**S3 website not accessible:**
- Verify `is_public` and `is_portfolio_website` are set to `true`
- Check bucket policy allows public read access
- Ensure index.html and error.html are uploaded

**DNS not resolving:**
- Verify Route53 hosted zone nameservers are set at your domain registrar
- Wait for DNS propagation (can take up to 48 hours)
- Use `dig` or `nslookup` to verify records

**Terraform state lock error:**
- Check S3 backend bucket exists and is accessible
- Verify encryption settings in backend configuration
- Use `terraform force-unlock` if needed (use with caution)

## 📦 Dependencies

- **Terraform**: ~> 1.14
- **AWS Provider**: ~> 6.0
- **AWS Account** with appropriate permissions
- **AWS CLI** (for backend setup)

## 🎯 Next Steps

Enhance your infrastructure with:
- [ ] Add CloudFront CDN for global distribution
- [ ] Implement SSL/TLS certificate management (ACM)
- [ ] Set up monitoring and logging
- [ ] Add automated backups
- [ ] Implement disaster recovery strategy
- [ ] Add custom domain SSL certificate

## 📖 Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [Route53 DNS Management](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices)

## 📄 License

This project is open source. Feel free to adapt it for your own use.

## 👤 Author

Created and maintained for personal portfolio infrastructure.

---

**Last Updated:** March 2026

For questions or improvements, feel free to contribute or create an issue!
