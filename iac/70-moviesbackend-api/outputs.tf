output "tls_name" {
  value = local.tls_name
}

output "api_fqdn" {
  value = local.api_fqdn
}

output "api_helm_template_manifest" {
  value = data.helm_template.api_helm_template.manifest
}

output "api_helm_template_manifests" {
  value = data.helm_template.api_helm_template.manifests
}

output "api_helm_template_notes" {
  value = data.helm_template.api_helm_template.notes
}