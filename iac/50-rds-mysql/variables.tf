variable "env" {
  description = "dev | staging | prod = acronym of the environment to be created. This is required to uniquely identify global resources or configure TFC organizations and AWS accounts."
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = null
}

variable "associated_product" {
  description = "Name of the product. For example, 'moviebackend-platform', that comprises all frontends and backends."
  type        = string
  default     = null
}

variable "db_subnet_group_name" {
  description = "The database subnet group name."
  type        = string
  default     = null
}

variable "cluster_allowed_cidr_blocks" {
  description = "The list of the allowed CIDRs to access the database nodes in the cluster."
  type        = list(string)
  default     = null
}

########################################################################################################################################################
# Below is the strategy for database maintenance. See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html
variable "db_cluster_preferred_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: ddd:hh24:mi-ddd:hh24:mi. Eg: Mon:00:00-Mon:03:00"
  type        = string
  # Region: Ireland (eu-west-1)
  default = null
}

variable "db_cluster_preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled."
  type        = string
  default     = null
}

variable "db_backup_retention_period" {
  description = "Days to retain backup"
  type        = number
  default     = null
}

variable "rds_instance_snapshot_arn" {
  description = "ARN of a database instance snapshot. If supplied, database cluster will be created using the snapshots for each RW/RO instance."
  type        = string
  default     = ""
}

variable "rds_kms_key_arn" {
  description = "ARN of the custom KMS key to encrypt/decrypt all RDS cluster data. If not supplied, Aurora will select aws/rds default key."
  type        = string
  default     = null
}

# Below is the strategy for database maintenance. See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html
########################################################################################################################################################

########################################################################################################################################################
# RDS engine, Horizontal and Vertical scaling

variable "rds_allow_major_version_upgrade" {
  description = "Allows major upgrades of MySQL Aurora."
  type        = bool
  default     = null
}

variable "rds_apply_immediately" {
  description = "RDS Engine changes (e.g. major/minor version, etc) apply immediately. Please note that not all configurations support this setting = true."
  type        = bool
  default     = null
}

variable "rds_engine" {
  description = "The RDS engine type (example: aurora)"
  type        = string
  default     = null
}

variable "rds_engine_version" {
  description = "The RDS engine version."
  type        = string
  default     = null
}

variable "rds_parameter_group_family" {
  description = "The RDS parameter group family."
  type        = string
  default     = null
}

variable "rds_cluster_parameter_group_family" {
  description = "The RDS parameter cluster group family."
  type        = string
  default     = null
}

variable "rds_cluster_instance_public" {
  description = "By default instances should be private."
  type        = bool
  default     = null
}

variable "rds_cluster_instance_class" {
  description = "If provided, overrides the types defined by the high_performance setting."
  type        = string
  default     = null
}

variable "rds_cluster_autoscalling_max_capacity" {
  description = "The maximum number of autoscaled nodes in the cluster."
  type        = number
  default     = null
}

variable "rds_cluster_initial_database" {
  description = "Creates an initial database upon cluster creation."
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Enable performance insights (advanced monitoring)."
  type        = bool
  default     = null
}

variable "high_performance" {
  description = "Set true to enable High Availability, Fault Tolerance and increased Horizontal and Vertical resource scaling. Apply it for production-like environments, e.g., Production, QA (Non-Functional), etc"
  type        = bool
  default     = null
}

# RDS engine, Horizontal and Vertical scaling
########################################################################################################################################################