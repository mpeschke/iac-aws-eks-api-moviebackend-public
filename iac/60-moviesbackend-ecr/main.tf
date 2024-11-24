locals {
  aws_region       = "us-east-1"
  environment_name = var.env
  repository_name  = "moviesbackend"
  tags = {
    iac_env        = local.environment_name,
    iac_managed_by = "terraform",

    iac_source_cd        = "https://app.terraform.io/app/mpeschke/workspaces/${local.environment_name}-60-mpeschke-org-moviesbackend-ecr",
    iac_source_repo      = "https://github.com/mpeschke/iac-aws-eks-api-moviebackend-public",
    iac_source_repo_path = "mpeschke.org/iac/${local.environment_name}/60-moviesbackend-ecr",
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
  # Public ECRs are supported only in us-east-1
  region = "us-east-1"
}

resource "aws_ecrpublic_repository_policy" "moviesbackend" {
  repository_name = aws_ecrpublic_repository.moviesbackend.repository_name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

resource "aws_ecrpublic_repository" "moviesbackend" {
  repository_name = local.repository_name

  force_destroy = true

  catalog_data {
    about_text        = "${local.repository_name} repository"
    architectures     = ["x86-64"]
    description       = "${local.repository_name} repository"
    operating_systems = ["Linux"]
    usage_text        = "${local.repository_name} repository"
  }

  tags = local.tags
}