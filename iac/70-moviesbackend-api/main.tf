locals {
  aws_region           = var.aws_region
  environment_name     = var.env
  service_name         = var.service_name
  api_fqdn             = "${var.service_name}.${data.terraform_remote_state.subdomain_records.outputs.domain_name}"
  tls_name             = "tls-${var.service_name}"
  chart_name           = "standard-application"
  chart_version        = "1.0.11"
  rendered_helm_values = "./rendered/values.yaml"
  tags = {
    iac_env              = "${local.environment_name}"
    iac_managed_by       = "terraform",
    iac_source_cd        = "https://app.terraform.io/app/mpeschke/workspaces/${local.environment_name}-70-mpeschke-org-moviesbackend-api",
    iac_source_repo      = "https://github.com/mpeschke/iac-aws-eks-api-moviebackend-public",
    iac_source_repo_path = "mpeschke.org/iac/${local.environment_name}/70-moviesbackend-api",
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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
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

data "terraform_remote_state" "docker_build_push" {
  backend = "remote"
  config = {
    # Update to your Terraform Cloud organization
    organization = "mpeschke"
    workspaces = {
      name = "${local.environment_name}-61-mpeschke-org-moviesbackend-docker-build-push"
    }
  }
}

data "terraform_remote_state" "rds" {
  backend = "remote"
  config = {
    # Update to your Terraform Cloud organization
    organization = "mpeschke"
    workspaces = {
      name = "${local.environment_name}-50-mpeschke-org-rds-mysql"
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
      args        = ["eks", "get-token", "--cluster-name", local.environment_name]
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
    fullnameoverride = local.service_name
    namespace        = local.service_name
    app              = local.service_name
    container_name   = local.service_name
    repository       = data.terraform_remote_state.ecr.outputs.ecr_uri
    tag              = data.terraform_remote_state.docker_build_push.outputs.docker_tag
    mysql_rw_cluster = data.terraform_remote_state.rds.outputs.db_cluster_rw_endpoint
    configenv        = var.config_env
    workers          = var.workers
    container_port   = var.container_port
    api_fqdn         = local.api_fqdn
    tls_name         = local.tls_name
  }
}

resource "local_file" "rendered_helm_values" {
  filename = local.rendered_helm_values
  content  = data.template_file.helm_values.rendered
}

# Running the template using local template files, rather than downloading the chart from the repository.
# Equivalent to running the command:
# helm template --values ${local.rendered_helm_values} ./
data "helm_template" "api_helm_template" {
  depends_on = [local_file.rendered_helm_values]

  name      = local.chart_name
  namespace = local.service_name

  chart   = "./"
  version = local.chart_version

  # TODO: update here the templates you want to be part of the generated manifest.
  show_only = [
    "templates/deployment.yaml",
    "templates/ingress.yaml",
    "templates/service.yaml",
  ]

  values = [local_file.rendered_helm_values.content]
}

# Equivalent to running the command:
# helm install moviesbackend ./ -n standard-application -f ${data.helm_template.api_helm_template.manifest} --create-namespace --namespace moviesbackend
data "helm_release" "api_helm_release" {
  depends_on = [
    local_file.rendered_helm_values,
    helm_template.api_helm_template,
  ]

  name             = local.chart_name
  namespace        = local.service_name
  create_namespace = true

  chart   = "./"
  version = local.chart_version

  values = [data.helm_template.api_helm_template.manifest]
}

