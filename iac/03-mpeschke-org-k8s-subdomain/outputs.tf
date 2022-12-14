output "zone_id" {
  description = "The hosted zone ID"
  value       = module.subdomain_hostedzone.zone_id
}

output "name_servers" {
  description = "The hosted zone name servers"
  value       = module.subdomain_hostedzone.name_servers
}

output "domain_name" {
  value = local.domain_name
}
