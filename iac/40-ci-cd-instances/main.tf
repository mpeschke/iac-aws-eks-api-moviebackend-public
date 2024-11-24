locals {
  aws_region            = var.aws_region
  environment_name      = var.env
  ci_cd_inst_base_name  = "ci-cd"
  ci_cd_key_name        = local.ci_cd_inst_base_name
  ci_cd_ssh_public_key  = var.ci_cd_ssh_public_key
  ci_cd_ssh_private_key = var.ci_cd_ssh_private_key
  ci_cd_instances = [
    {
      instance_type     = "t2.small"
      ami_values        = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
      monitoring        = true
      source_dest_check = false
      root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 200
          volume_size = 50
        }
      ]
    }
  ]

  tags = {
    iac_env              = local.environment_name,
    iac_managed_by       = "terraform",
    iac_source_cd        = "https://app.terraform.io/app/mpeschke/workspaces/${local.environment_name}-40-mpeschke-org-ci-cd-instances",
    iac_source_repo      = "https://github.com/mpeschke/iac-aws-eks-api-moviebackend-public",
    iac_source_repo_path = "mpeschke.org/iac/${local.environment_name}/40-ci-cd-instances",
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

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    # Update to your Terraform Cloud organization
    organization = "mpeschke"
    workspaces = {
      name = "${local.environment_name}-10-mpeschke-org-vpc"
    }
  }
}