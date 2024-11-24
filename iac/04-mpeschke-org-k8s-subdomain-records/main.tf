locals {
  aws_region       = var.aws_region
  environment_name = var.env
  domain_name      = var.env_domain_name
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

data "terraform_remote_state" "sub_domain" {
  backend = "remote"

  config = {
    # Update to your Terraform Cloud organization
    organization = "mpeschke"
    workspaces = {
      name = "${local.environment_name}-03-mpeschke-org-k8s-subdomain"
    }
  }
}

resource "aws_route53_record" "k8s-subdomain" {
  allow_overwrite = true
  name            = local.domain_name
  ttl             = 172800
  type            = "NS"
  zone_id         = data.terraform_remote_state.parent_domain.outputs.zone_id

  records = data.terraform_remote_state.sub_domain.outputs.name_servers
}
