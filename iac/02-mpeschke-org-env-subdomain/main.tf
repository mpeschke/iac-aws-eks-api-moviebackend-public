locals {
  aws_region  = var.aws_region
  environment_name = var.env
  domain_name = var.env_domain_name
  tags = {
    iac_env              = "${local.environment_name}"
    iac_managed_by       = "terraform",
    iac_source_cd        = "https://app.terraform.io/app/mpeschke/workspaces/${local.environment_name}-02-mpeschke-org-k8s-subdomain",
    iac_source_repo      = "https://github.com/mpeschke/iac-aws-eks-api-moviebackend-public",
    iac_source_repo_path = "mpeschke.org/iac/${local.environment_name}/02-mpeschke-org-k8s-subdomain",
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
  alias = "environment"
  profile = "mpeschke-staging-tfc"
  region = local.aws_region
}

provider "aws" {
  alias = "parent"
  access_key = var.PARENT_ACCESS_KEY
  secret_key = var.PARENT_SECRET_KEY
  region = local.aws_region
}

data "terraform_remote_state" "parent_domain" {
  backend = "remote"
  
  config = {
    # Update to your Terraform Cloud organization
    organization = "mpeschke"
    workspaces = {
      name = "prod-01-mpeschke-org-wildcard-domain"
    }
  }
}

#
# Route53 Hosted Zone for the Environment
#
resource "aws_route53_zone" "environment" {
  provider = aws.environment
  
  name = local.domain_name

  tags = local.tags
}

resource "aws_route53_record" "ns_parent_to_environment" {
  provider = aws.parent

  allow_overwrite = true
  name            = local.domain_name
  ttl             = 172800
  type            = "NS"
  zone_id         = data.terraform_remote_state.parent_domain.outputs.zone_id

  records = aws_route53_zone.environment.name_servers
}
