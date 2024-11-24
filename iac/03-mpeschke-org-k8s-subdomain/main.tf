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

#
# Route53 Hosted Zone
#
module "subdomain_hostedzone" {
  source = "github.com/ManagedKube/kubernetes-ops//terraform-modules/aws/route53/hosted-zone?ref=v1.0.30"

  domain_name = local.domain_name
  tags        = local.tags
}
# TODO: Enable CloudWatch alarms to monitor critical DNS security issues. See https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-configuring-dnssec.html
