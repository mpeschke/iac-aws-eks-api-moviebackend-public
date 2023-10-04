variable "env" {
    description = "dev | staging | prod = acronym of the environment to be created. This is required to uniquely identify global resources or configure TFC organizations and AWS accounts."
    type = string
    default = null
}

variable "aws_region" {
    description = "AWS Region to host cloud resources."
    type = string
    default = null
}

variable "letsencrypt_stg" {
    description = "true: recommended LetsEncrypt Staging Server for non-production TLS certificates. See https://letsencrypt.org/docs/staging-environment/"
    type = bool
    default = null
}

variable "letsencrypt_email" {
    description = "The email that will get LetsEncrypt certbot messages."
    type = string
    default = null
}