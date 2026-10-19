# aws-terraform-foundation

![Terraform CI](https://github.com/ayeshaakhtar0134/aws-terraform-foundation/actions/workflows/terraform.yml/badge.svg)

A production-style AWS network and security baseline built entirely with **Terraform**: a multi-AZ VPC with public and private subnets, NAT, least-privilege IAM, and remote state in S3 with DynamoDB locking. Separate `dev` and `prod` environments reuse the same modules.

## Architecture

```
                        Internet
                           │
                    ┌──────┴──────┐
                    │ Internet GW │
                    └──────┬──────┘
          ┌────────────────┴────────────────┐
   ┌──────┴───────┐                  ┌──────┴───────┐
   │ Public  AZ-a │                  │ Public  AZ-b │
   │  NAT Gateway │                  │              │
   └──────┬───────┘                  └──────────────┘
          │ (egress only)
   ┌──────┴───────┐                  ┌──────────────┐
   │ Private AZ-a │                  │ Private AZ-b │
   └──────────────┘                  └──────────────┘
                  VPC 10.0.0.0/16 (dev)

  State: S3 bucket (versioned, encrypted)  +  DynamoDB lock table
```

Replace this with a diagram exported to `docs/architecture.png` (draw.io or Excalidraw).

## Tech stack

Terraform ≥ 1.6 · AWS provider 5.x · GitHub Actions · tflint · checkov

## Repository layout

```
bootstrap/        One-time: creates the S3 state bucket + DynamoDB lock table
modules/vpc/      VPC, subnets across AZs, IGW, NAT, route tables
modules/iam/      EC2 instance role with SSM access (least privilege)
envs/dev/         Dev environment (single NAT to save cost)
envs/prod/        Prod environment (one NAT per AZ for high availability)
.github/workflows/terraform.yml   fmt, validate, tflint and checkov on every push/PR
```

## How to deploy

Prerequisites: an AWS account, AWS CLI configured, Terraform ≥ 1.6.

```bash
# 1. Create the remote state backend (once)
cd bootstrap
terraform init && terraform apply -var="state_bucket_name=<globally-unique-name>"

# 2. Point envs/dev/backend.tf at that bucket, then deploy dev
cd ../envs/dev
terraform init
terraform plan
terraform apply
```

## How to destroy

```bash
cd envs/dev && terraform destroy
```

⚠️ The NAT gateway costs roughly **$1/day**. Destroy the environment when you are not using it.

## Estimated cost

| Resource | Dev (approx.) |
|----------|---------------|
| NAT Gateway | ~$32/month + data |
| VPC, subnets, IAM, S3 state, DynamoDB | ~$0–1/month |

## Screenshots

Add to `docs/` after deploying: `terraform apply` output, VPC resource map in the AWS console, green CI run.

## What I learned

- *Write 3–5 bullets here after building it: e.g. why remote state needs locking, how NAT per AZ trades cost for availability, a bug you hit and fixed.*

## Roadmap

- [ ] Add VPC flow logs to CloudWatch
- [ ] Add GitHub Actions OIDC role and `terraform plan` on PRs against AWS
- [ ] Add bastion-less access via SSM Session Manager demo instance
