locals {
  aws_region       = var.aws_region
  environment_name = var.env
  tags = {
    iac_env              = "${local.environment_name}"
    iac_managed_by       = "terraform",
    iac_source_cd        = "https://app.terraform.io/app/mpeschke/workspaces/${local.environment_name}-10-mpeschke-org-vpc",
    iac_source_repo      = "https://github.com/mpeschke/iac-aws-eks-api-moviebackend-public",
    iac_source_repo_path = "mpeschke.org/iac/${local.environment_name}/10-vpc",
    iac_owners           = "devops",
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.38.0"
    }
  }

  backend "remote" {}
}

provider "aws" {
  region = local.aws_region
}

#
# VPC
#
module "vpc" {
  # This 1.0.30 module is now incompatible with more recent aws provider versions (5.x)
  source = "github.com/ManagedKube/kubernetes-ops//terraform-modules/aws/vpc?ref=v1.0.30"

  aws_region       = local.aws_region
  azs              = var.azs
  vpc_cidr         = var.vpc_cidr
  private_subnets  = var.private_subnets_cidrs
  public_subnets   = var.public_subnets_cidrs
  environment_name = local.environment_name
  cluster_name     = local.environment_name
  tags             = local.tags
}
