output "zone_id" {
  description = "The hosted zone ID"
  value       = aws_route53_zone.parent.zone_id
}

output "name_servers" {
  description = "The hosted zone name servers"
  value       = aws_route53_zone.parent.name_servers
}

output "domain_name" {
  value = local.domain_name
}
