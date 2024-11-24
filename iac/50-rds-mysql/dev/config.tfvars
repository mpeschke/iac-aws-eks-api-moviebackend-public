# Important: senstitive data must NOT be here.
# Sensitive data must only be provided via TFC write-only variables in conjunction with Hashicorp Vault or any other secure data store.
env                                     = "dev"
aws_region                              = "eu-west-1"
associated_product                      = "moviesbackend"
db_subnet_group_name                    = "moviesbackend"
cluster_allowed_cidr_blocks             = ["0.0.0.0/0"]
db_cluster_preferred_maintenance_window = "Mon:22:00-Tue:02:00"
db_cluster_preferred_backup_window      = "06:00-11:00"
db_backup_retention_period              = 7
rds_instance_snapshot_arn               = ""
rds_kms_key_arn                         = ""
rds_allow_major_version_upgrade         = false
rds_apply_immediately                   = true
rds_engine                              = "aurora-mysql"
rds_engine_version                      = "5.7.mysql_aurora.2.11.3"
rds_parameter_group_family              = "aurora-mysql5.7"
rds_cluster_parameter_group_family      = "aurora-mysql5.7"
rds_cluster_instance_public             = false
rds_cluster_instance_class              = ""
rds_cluster_autoscalling_max_capacity   = 6
# should rds_cluster_initial_database be provided?
performance_insights_enabled = false
high_performance             = false
