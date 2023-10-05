locals {
  aws_region        = "us-east-1"
  environment_name  = var.env
  docker_tag        = var.docker_tag
  repository_branch = var.repository_branch
  repository_name   = "moviesbackend"
  tags = {
    iac_env              = local.environment_name,
    iac_managed_by       = "terraform",

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

data "terraform_remote_state" "ci_cd_instances" {
  backend = "remote"
  config = {
    # Update to your Terraform Cloud organization
    organization = "mpeschke"
    workspaces = {
      name = "${local.environment_name}-40-mpeschke-org-ci-cd-instances"
    }
  }
}

data "terraform_remote_state" "ecr" {
  backend = "remote"
  config = {
    # Update to your Terraform Cloud organization
    organization = "mpeschke"
    workspaces = {
      name = "${local.environment_name}-60-mpeschke-org-moviesbackend-ecr"
    }
  }
}

resource "null_resource" "push_moviesbackend" {
  connection {
    user = "ubuntu"
    private_key = replace("${data.terraform_remote_state.ci_cd_instances.outputs.ci_cd_ssh_private_key}", "\\n", "\n")
    host = data.terraform_remote_state.ci_cd_instances.outputs.ci_cd_eip_public_ips[0]
  }

# Example:
# git clone --branch release/v0.1.0 https://bitbucket.org/matheuspeschke/moviesbackend
# sudo docker build --tag moviesbackend:0.1.0 moviesbackend/ -f moviesbackend/Dockerfile
# aws ecr-public get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin public.ecr.aws/o1m8n6c3/moviesbackend
# sudo docker tag moviesbackend:0.1.0 public.ecr.aws/o1m8n6c3/moviesbackend:0.1.0
# sudo docker push public.ecr.aws/o1m8n6c3/moviesbackend:0.1.0

  provisioner "remote-exec" {
      inline = [
        "git clone --branch ${local.repository_branch} https://bitbucket.org/matheuspeschke/${local.repository_name}",
        # TODO: this mess should be fixed in a new release or use helm chart app to have WEBSERVPORT value passed as a templated value.
        #"sed -i 's/WEBSERVPORT=5000/WEBSERVPORT=80/' ${local.repository_name}/Dockerfile",
        "sudo docker build --tag ${local.repository_name}:${local.docker_tag} ${local.repository_name}/ -f ${local.repository_name}/Dockerfile",
        "aws ecr-public get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin ${data.terraform_remote_state.ecr.outputs.ecr_uri}",
        "sudo docker tag ${local.repository_name}:${local.docker_tag} ${data.terraform_remote_state.ecr.outputs.ecr_uri}:${local.docker_tag}",
        "sudo docker push ${data.terraform_remote_state.ecr.outputs.ecr_uri}:${local.docker_tag}"
      ]
  }
}