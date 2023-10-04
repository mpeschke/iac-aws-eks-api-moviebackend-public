output "ci_cd_aws_amis" {
  value = data.aws_ami.ci_cd_amis
}

output "ci_cd_eip_public_ips" {
  value = aws_eip.ci_cd_eips[*].public_ip
}

output "ci_cd_ssh_public_key" {
  value = local.ci_cd_ssh_public_key
}

output "ci_cd_ssh_private_key" {
  value = local.ci_cd_ssh_private_key
  sensitive = true
}