locals {
  aws_region           = var.aws_region
  environment_name     = var.env
  grafana_fqdn         = "grafana.${data.terraform_remote_state.subdomain_records.outputs.domain_name}"
  rendered_helm_values = "./rendered/values.yaml"
  tags = {
    iac_env              = "${local.environment_name}"
    iac_managed_by       = "terraform",
    iac_source_cd        = "https://app.terraform.io/app/mpeschke/workspaces/${local.environment_name}-34-mpeschke-org-helm-prometheus-stack",
    iac_source_repo      = "https://github.com/mpeschke/iac-aws-eks-api-moviebackend-public",
    iac_source_repo_path = "mpeschke.org/iac/${local.environment_name}/30-helm/34-kube-prometheus-stack",
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
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

  backend "remote" {}
}

provider "aws" {
  region = local.aws_region
}

data "terraform_remote_state" "eks" {
  backend = "remote"
  config = {
    # Update to your Terraform Cloud organization
    organization = "mpeschke"
    workspaces = {
      name = "${local.environment_name}-20-mpeschke-org-eks"
    }
  }
}

data "terraform_remote_state" "subdomain_records" {
  backend = "remote"
  config = {
    # Update to your Terraform Cloud organization
    organization = "mpeschke"
    workspaces = {
      name = "${local.environment_name}-04-mpeschke-org-k8s-subdomain-records"
    }
  }
}

#
# EKS authentication
# # https://registry.terraform.io/providers/hashicorp/helm/latest/docs#exec-plugins
provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", "${local.environment_name}"]
      command     = "aws"
    }
  }
}

data "aws_eks_cluster_auth" "main" {
  name = local.environment_name
}

provider "kubectl" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.main.token
  load_config_file       = false
}

# Helm values file templating
data "template_file" "helm_values" {
  template = file("${path.module}/${var.env}/values.yaml.tpl")

  # Parameters you want to pass into the values.yaml.tpl file to be templated
  vars = {
    admin_password = var.admin_password
    grafana_fqdn   = local.grafana_fqdn
  }
}

resource "local_file" "rendered_helm_values" {
  filename = local.rendered_helm_values
  content  = data.template_file.helm_values.rendered
}

#
# Helm - kube-prometheus-stack
#
module "kube-prometheus-stack" {
  source = "github.com/ManagedKube/kubernetes-ops//terraform-modules/aws/helm/kube-prometheus-stack?ref=v1.0.15"

  depends_on = [
    data.terraform_remote_state.eks,
    local_file.rendered_helm_values,
  ]

  helm_values = file("${path.module}/rendered/values.yaml")
}
