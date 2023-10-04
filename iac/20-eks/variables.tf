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

variable "cluster_version" {
    description = "EKS cluster engine version."
    type = string
    default = null
}

variable "aws_auth_users" {
    description = "A list of users with access to the EKS cluster."
    type    = list(object({
    userarn = string
    username = string
    groups = list(string)
  }))
    default = null
}