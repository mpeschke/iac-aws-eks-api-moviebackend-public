# Important: senstitive data must NOT be here.
# Sensitive data must only be provided via TFC write-only variables in conjunction with Hashicorp Vault or any other secure data store.
env = "dev"
aws_region = "eu-west-1"
cluster_version = "1.23"
aws_auth_users = [
    {
      userarn  = "arn:aws:iam::094509570164:user/matheus.peschke"
      username = "matheus.peschke"
      groups   = ["system:masters"]
    },
  ]