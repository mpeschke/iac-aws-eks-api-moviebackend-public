locals {
  aws_region       = var.aws_region
  environment_name = var.env
  tags = {
    iac_env              = local.environment_name,
    iac_managed_by       = "terraform",
    iac_source_cd        = "https://app.terraform.io/app/mpeschke/workspaces/${local.environment_name}-20-mpeschke-org-eks",
    iac_source_repo      = "https://github.com/mpeschke/iac-aws-eks-api-moviebackend-public",
    iac_source_repo_path = "mpeschke.org/iac/${local.environment_name}/20-eks",
    iac_owners           = "devops",
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.37.0"
    }
    random = {
      source = "hashicorp/random"
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

#
# EKS
#
module "eks" {
  source = "github.com/ManagedKube/kubernetes-ops//terraform-modules/aws/eks?ref=v2.0.59"

  aws_region = local.aws_region
  tags       = local.tags

  cluster_name = local.environment_name

  vpc_id         = data.terraform_remote_state.vpc.outputs.vpc_id
  k8s_subnets    = data.terraform_remote_state.vpc.outputs.k8s_subnets
  public_subnets = data.terraform_remote_state.vpc.outputs.public_subnets

  cluster_version = var.cluster_version

  # public cluster - kubernetes API is publicly accessible
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = [
    "0.0.0.0/0",
    "1.1.1.1/32",
  ]

  # private cluster - kubernetes API is internal the the VPC
  cluster_endpoint_private_access = true
  cluster_kms_enable_rotation     = false

  # Add whatever roles and users you want to access your cluster
  aws_auth_users = var.aws_auth_users

  eks_managed_node_groups = {
    ng1 = {
      create_launch_template = false
      launch_template_name   = ""

      # Doc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
      # (Optional) Force version update if existing pods are unable to be drained due to a pod disruption budget issue.
      force_update_version = true

      # doc: https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami
      # doc: https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami-bottlerocket.html
      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"
      version  = "1.23"

      disk_size       = 20
      desired_size    = 3
      max_size        = 30
      min_size        = 3
      instance_types  = ["t2.small"]
      additional_tags = {
        Name = "ng1",
      }
      k8s_labels = {}
    }
  }
}
