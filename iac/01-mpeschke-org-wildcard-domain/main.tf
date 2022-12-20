locals {
  aws_region  = var.aws_region
  environment_name = var.env
  domain_name = var.wildcard_domain_name
  tags = {
    iac_env              = var.env
    iac_managed_by       = "terraform",
    iac_source_cd        = "https://app.terraform.io/app/mpeschke/workspaces/${var.env}-01-mpeschke-org-wildcard-domain",
    iac_source_repo      = "https://github.com/mpeschke/iac-aws-eks-api-moviebackend-public",
    iac_source_repo_path = "mpeschke.org/iac/${var.env}/01-mpeschke-org-wildcard-domain",
    iac_owners           = "devops",
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.37.0"
    }
  }

  backend "remote" {}
}

provider "aws" {
  region = local.aws_region
}

#
# Route53 Hosted Zone
#
resource "aws_route53_zone" "parent" {
  name = local.domain_name

  tags = local.tags
}