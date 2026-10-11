# GitHub Actions → AWS (OIDC) setup

The `Terraform` workflow (`.github/workflows/terraform.yml`) authenticates to AWS
with GitHub's OIDC provider, so no long-lived AWS keys are stored in GitHub.

It uses two IAM roles:

| Role | Used by | Trusted for | Can do |
|---|---|---|---|
| `github-terraform-plan` | `plan` job on pull requests | `repo:vict-devv/personal-terraform:pull_request` | Read everything, plus write the state lock file |
| `github-terraform-deploy` | `deploy` job on `main` | `repo:vict-devv/personal-terraform:ref:refs/heads/main` | Manage the portfolio's S3, CloudFront, ACM and Route53 resources, and the state |

Splitting them means code in an unmerged PR can never change infrastructure;
only commits that land on `main` can.

These roles are created once by hand (they cannot be created by the same
Terraform they authorise). Replace `<ACCOUNT_ID>` and `<DOMAIN>` below
(e.g. `vict-devv.com`).

## 1. Create the GitHub OIDC identity provider

Skip if `token.actions.githubusercontent.com` already exists under
IAM → Identity providers.

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com
```

## 2. Plan role (read-only, pull requests)

`plan-trust.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:vict-devv/personal-terraform:pull_request"
        }
      }
    }
  ]
}
```

`plan-state-lock.json` (plan takes the S3 state lock, which writes a
`.tflock` object):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "StateLock",
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::victor-devops-tfstate-bucket/personal/terraform.tfstate.tflock"
    }
  ]
}
```

```bash
aws iam create-role --role-name github-terraform-plan \
  --assume-role-policy-document file://plan-trust.json
aws iam attach-role-policy --role-name github-terraform-plan \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
aws iam put-role-policy --role-name github-terraform-plan \
  --policy-name terraform-state-lock \
  --policy-document file://plan-state-lock.json
```

## 3. Deploy role (main branch)

`deploy-trust.json`: same as `plan-trust.json`, with the `sub` changed to
`repo:vict-devv/personal-terraform:ref:refs/heads/main`.

`deploy-permissions.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TerraformState",
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::victor-devops-tfstate-bucket"
    },
    {
      "Sid": "TerraformStateObjects",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::victor-devops-tfstate-bucket/personal/*"
    },
    {
      "Sid": "PortfolioBucket",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::www.<DOMAIN>",
        "arn:aws:s3:::www.<DOMAIN>/*"
      ]
    },
    {
      "Sid": "CloudFrontAcmRoute53",
      "Effect": "Allow",
      "Action": ["cloudfront:*", "acm:*", "route53:*"],
      "Resource": "*"
    }
  ]
}
```

If the state bucket uses SSE-KMS with a customer-managed key, also grant
`kms:Decrypt`, `kms:Encrypt` and `kms:GenerateDataKey` on that key to both
roles. With the default S3-managed encryption nothing more is needed.

```bash
aws iam create-role --role-name github-terraform-deploy \
  --assume-role-policy-document file://deploy-trust.json
aws iam put-role-policy --role-name github-terraform-deploy \
  --policy-name terraform-deploy \
  --policy-document file://deploy-permissions.json
```

## 4. Configure the GitHub repository

Settings → Secrets and variables → Actions → **Variables** tab
(these are not secret, so plain variables are fine):

| Variable | Value |
|---|---|
| `AWS_PLAN_ROLE_ARN` | `arn:aws:iam::<ACCOUNT_ID>:role/github-terraform-plan` |
| `AWS_DEPLOY_ROLE_ARN` | `arn:aws:iam::<ACCOUNT_ID>:role/github-terraform-deploy` |
| `DOMAIN_NAME` | `<DOMAIN>` (replaces the local, git-ignored `terraform.tfvars`) |

Until `AWS_PLAN_ROLE_ARN` / `AWS_DEPLOY_ROLE_ARN` are set, the `plan` and
`deploy` jobs are skipped and only the format/validate job runs, so merging the
workflow before the roles exist is safe.

## Optional: require approval before apply

To review each deploy before it runs, add `environment: production` to the
`deploy` job, create a `production` environment with required reviewers, and
change the deploy role's trust `sub` to
`repo:vict-devv/personal-terraform:environment:production` (the token's
subject switches to the environment once a job uses one).
