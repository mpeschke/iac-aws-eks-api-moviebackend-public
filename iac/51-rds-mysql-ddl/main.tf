locals {
  aws_region       = var.aws_region
  environment_name = var.env
  tags = {
    iac_env              = local.environment_name,
    iac_managed_by       = "terraform",
    iac_source_cd        = "https://app.terraform.io/app/mpeschke/workspaces/${local.environment_name}-51-mpeschke-org-rds-mysql-ddl",
    iac_source_repo      = "https://github.com/mpeschke/iac-aws-eks-api-moviebackend-public",
    iac_source_repo_path = "mpeschke.org/iac/${local.environment_name}/51-rds-mysql-ddl",
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

# Create the Database DDL.
resource "null_resource" "db_setup" {
  triggers = {
    file = filesha1("ddl.sql")
  }

  connection {
    user        = "ubuntu"
    private_key = replace("${data.terraform_remote_state.ci_cd_instances.outputs.ci_cd_ssh_private_key}", "\\n", "\n")
    host        = data.terraform_remote_state.ci_cd_instances.outputs.ci_cd_eip_public_ips[0]
  }

  provisioner "file" {
    source      = "ddl.sql"
    destination = "/home/ubuntu/ddl.sql"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 90",
      "sudo docker run --name movies-mysql --net=host -e MYSQL_ROOT_PASSWORD=\"WhAtEvEr1234.4321234\" -d mysql:5.7",
      "sudo docker exec -i movies-mysql mysql --host=\"${data.terraform_remote_state.rds.outputs.db_cluster_rw_endpoint}\" --user=\"${data.terraform_remote_state.rds.outputs.db_cluster_master_user}\" --password=\"${data.terraform_remote_state.rds.outputs.db_cluster_master_password}\" --force < /home/ubuntu/ddl.sql",
      "sudo docker stop movies-mysql",
      "sudo docker rm movies-mysql"
    ]
  }
}