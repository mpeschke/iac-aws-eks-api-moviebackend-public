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

variable "env_domain_name" {
    description = "A subdomain to host environment's resources. Example of environment subdomains: staging.mpeschke.org, dev.mpeschke.org, etc."
    type = string
    default = null
}

variable "PARENT_ACCESS_KEY" {
    description = "AWS access key to the AWS account where the parent domain's Route53 Hosted Zone was created."
    type = string
    default = null
}

variable "PARENT_SECRET_KEY" {
    description = "AWS secret key to the AWS account where the parent domain's Route53 Hosted Zone was created."
    type = string
    default = null
}

