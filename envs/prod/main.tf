terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = "aws-terraform-foundation"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

module "vpc" {
  source             = "../../modules/vpc"
  name               = "foundation-prod"
  cidr_block         = "10.1.0.0/16"
  azs                = ["${var.region}a", "${var.region}b"]
  single_nat_gateway = false
}

module "iam" {
  source = "../../modules/iam"
  name   = "foundation-prod"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}
