variable "env" {
    description = "dev | staging | prod = acronym of the environment to be created. This is required to uniquely identify global resources or configure TFC organizations and AWS accounts."
    type = string
    default = null
}

variable "aws_region" {
    description = "AWS region"
    type = string
    default = null
}

variable "ci_cd_ssh_private_key" {
    description = "The content of a local SSH private key - to run commands remotely on the EC2 public instance."
    type = string
    default = null
}

variable "ci_cd_ssh_public_key" {
    description = "The content of a local SSH public key - to run commands remotely on the EC2 public instance."
    type = string
    default = null
}