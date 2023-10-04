# RDS Aurora MySQL
output "db_cluster_master_user" {
    description = "Master user to connect to the database."
    value = module.cluster.cluster_master_username
    sensitive = true
}

output "db_cluster_master_password" {
    description = "Master password will only be available in TFC."
    value = random_password.master_password.result
    sensitive = true
}

output "db_cluster_rw_endpoint" {
    description = "A read-write endpoint to the cluster."
    value = module.cluster.cluster_endpoint
}

output "db_cluster_ro_endpoint" {
    description = "A readonly endpoint to the cluster."
    value = module.cluster.cluster_reader_endpoint
}

output "db_cluster_cluster_arn" {
    description = "The cluster ARN."
    value = module.cluster.cluster_arn
}

output "db_cluster_secret_arn" {
    description = "The secret's ARN."
    value = aws_secretsmanager_secret_version.db-pass-val.arn
}