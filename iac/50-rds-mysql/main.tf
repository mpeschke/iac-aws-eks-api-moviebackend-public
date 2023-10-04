# Initial implementation is hard-coded to two AZs. In the future, implement a logic
# to deploy dynamically writers and readers balanced in more than 2 AZs.
locals {
  rds_db_cluster_instances                = var.rds_instance_snapshot_arn == "" ? { one = {publicly_accessible = var.rds_cluster_instance_public}, two = {publicly_accessible = var.rds_cluster_instance_public}, three = {publicly_accessible = var.rds_cluster_instance_public} } : { one = {publicly_accessible = var.rds_cluster_instance_public, snapshot_identifier = var.rds_instance_snapshot_arn}, two = {publicly_accessible = var.rds_cluster_instance_public, snapshot_identifier = var.rds_instance_snapshot_arn}, three = {publicly_accessible = var.rds_cluster_instance_public, snapshot_identifier = var.rds_instance_snapshot_arn} }
  rds_db_cluster_autoscaling_min_capacity = 3 # start with one reader and one writer.
  rds_db_cluster_autoscaling_max_capacity = var.rds_cluster_autoscalling_max_capacity
  rds_db_cluster_instance_class           = var.rds_cluster_instance_class != "" ? var.rds_cluster_instance_class : (var.high_performance ? "db.r5.xlarge" : "db.t3.medium")
  rds_db_cluster_initial_db               = var.rds_cluster_initial_database

  aws_region         = var.aws_region
  environment_name   = var.env
  tags = {
    iac_env              = local.environment_name,
    iac_managed_by       = "terraform",
    iac_source_cd        = "https://app.terraform.io/app/mpeschke/workspaces/${local.environment_name}-50-mpeschke-org-rds-mysql",
    iac_source_repo      = "https://github.com/mpeschke/iac-aws-eks-api-moviebackend-public",
    iac_source_repo_path = "mpeschke.org/iac/${local.environment_name}/50-rds-mysql",
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
      version = ">= 3.5.1"
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

# RDS Aurora MySQL - main database
# Current implementation: MySQL 5.7 (5.7.mysql_aurora.2.03.2)
resource "random_password" "master_password" {
  length           = 20
  special          = true
  min_special       = 5
  # Make sure these characters 1) are valid MySql passwords and 2) won't mess with bash commands.
  override_special = "-_=+[]{}"
}

# secret to store the password
resource "aws_secretsmanager_secret" "db-pass" {
  name = "db-pass-xpto-${local.environment_name}"
  recovery_window_in_days = 0
  tags = local.tags
}

# initial value
resource "aws_secretsmanager_secret_version" "db-pass-val" {
  depends_on = [
    module.cluster
  ]

  secret_id = aws_secretsmanager_secret.db-pass.id
  secret_string = jsonencode(
    {
      username = module.cluster.cluster_master_username
      password = random_password.master_password.result
      engine   = "mysql"
      host     = module.cluster.cluster_endpoint
    }
  )
}

module "cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  # Freeze versions - don't rely on latest versions as they might introduce non-tested changes during deploy.
  version = "6.0.0"

  name           = "${var.associated_product}-aurora-mysql"
  # See https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Updates.20180206.html#AuroraMySQL.Updates.20180206.CLI
  # The engine name for Aurora MySQL 2.x is aurora-mysql; the engine name for Aurora MySQL 1.x continues to be aurora.
  # The engine version for Aurora MySQL 2.x is 5.7.12; the engine version for Aurora MySQL 1.x continues to be 5.6.10ann
  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  allow_major_version_upgrade = var.rds_allow_major_version_upgrade

  autoscaling_enabled          = true
  performance_insights_enabled = var.performance_insights_enabled

  instances                = local.rds_db_cluster_instances
  instance_class           = local.rds_db_cluster_instance_class
  autoscaling_min_capacity = local.rds_db_cluster_autoscaling_min_capacity
  autoscaling_max_capacity = local.rds_db_cluster_autoscaling_max_capacity

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  db_subnet_group_name   = var.db_subnet_group_name
  create_db_subnet_group = true
  subnets = data.terraform_remote_state.vpc.outputs.private_subnets
  create_security_group  = true
  allowed_cidr_blocks    = var.cluster_allowed_cidr_blocks

# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Enabling.html
  iam_database_authentication_enabled = false
# Master password won't be available on RDS Aurora console!
  master_password                     = random_password.master_password.result
  create_random_password              = false

  monitoring_interval           = 60
  iam_role_name                 = "${var.associated_product}-aurora-mysql-monitor"
  iam_role_use_name_prefix      = true
  iam_role_description          = "${var.associated_product}-aurora-mysql RDS enhanced monitoring IAM role"
  iam_role_path                 = "/autoscaling/"
  iam_role_max_session_duration = 7200

  apply_immediately   = var.rds_apply_immediately
  skip_final_snapshot = true

  storage_encrypted   = true
  kms_key_id = var.rds_kms_key_arn

  db_parameter_group_name         = aws_db_parameter_group.cluster.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster.id
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

# Maintenance and Backup options.
  backup_retention_period = var.db_backup_retention_period
  preferred_backup_window = var.db_cluster_preferred_backup_window
  preferred_maintenance_window = var.db_cluster_preferred_maintenance_window

# Create a database upon cluster creation.
  database_name = local.rds_db_cluster_initial_db

# Always copy the tag information of the cluster to the snapshots (helps to track origin)
  copy_tags_to_snapshot = true
  tags = local.tags
}

resource "aws_db_parameter_group" "cluster" {
  name_prefix = "${var.associated_product}-aurora-mysql-parameter-group"
  family      = var.rds_parameter_group_family
  description = "Parameter group for the databases in cluster ${var.associated_product}-aurora-mysql"

  lifecycle {
    create_before_destroy = true
  }

  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "cluster" {
  name_prefix = "${var.associated_product}-aurora-mysql-cluster-parameter-group"
  family      = var.rds_cluster_parameter_group_family
  description = "${var.associated_product}-aurora-mysql cluster parameter group"

  lifecycle {
    create_before_destroy = true
  }

  tags        = local.tags
}
