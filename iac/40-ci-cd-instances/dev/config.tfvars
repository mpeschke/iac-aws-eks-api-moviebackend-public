# Important: senstitive data must NOT be here.
# Sensitive data must only be provided via TFC write-only variables in conjunction with Hashicorp Vault or any other secure data store.
env                  = "dev"
aws_region           = "eu-west-1"
ci_cd_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEEP50cskecZQ9IZate3kpkPvzHMsEB2v2E0VI7QoKy"
# The content of the private key should be one line, with new lines marked like this:
# "-----BEGIN OPENSSH PRIVATE KEY-----\nAAAA\nBBBB\nCCCC\nDDDD\nEEEE\n-----END OPENSSH PRIVATE KEY-----"
ci_cd_ssh_private_key       = ""
CI_CD_AWS_ACCESS_KEY_ID     = ""
CI_CD_AWS_SECRET_ACCESS_KEY = ""