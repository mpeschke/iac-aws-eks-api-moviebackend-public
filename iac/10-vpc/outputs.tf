output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR for this VPC."
  value       = var.vpc_cidr
}

output "private_subnets" {
  description = "A list of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidrs" {
  description = "A list of CIDRs for the Private Subnets."
  value       = var.private_subnets_cidrs
}

output "public_subnets" {
  description = "A list of public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnets_cidrs" {
  description = "A list of CIDRs for the Public Subnets."
  value       = var.public_subnets_cidrs
}

output "k8s_subnets" {
  description = "A list of k8s subnets"
  value       = module.vpc.k8s_subnets
}

output "azs" {
  description = "A list of the Availability Zones"
  value       = var.azs
}
