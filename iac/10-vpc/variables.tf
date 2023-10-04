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

variable "azs" {
    description = "A list of the Availability Zones."
    type = list(string)
    default = null
}

variable "vpc_cidr" {
    description = "The CIDR for this VPC."
    type = string
    default = null
}

variable "private_subnets_cidrs" {
    description = "A list of CIDRs for the Private Subnets."
    type = list(string)
    default = null
}

variable "public_subnets_cidrs" {
    description = "A list of CIDRs for the Public Subnets."
    type = list(string)
    default = null
}