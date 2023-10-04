variable "env" {
    description = "dev | staging | prod = acronym of the environment to be created. This is required to uniquely identify global resources or configure TFC organizations and AWS accounts."
    type = string
    default = null
}

variable "docker_tag" {
    description = "The name of the tag for the Docker image."
    type = string
    default = null
}

variable "repository_branch" {
    description = "The git branch or tag that represents the docker tag."
    type = string
    default = null
}

variable "CI_CD_AWS_ACCESS_KEY_ID" {
    description = "The AWS access key ID with permissions to manage resources."
    type = string
    default = ""
}

variable "CI_CD_AWS_SECRET_ACCESS_KEY" {
    description = "The AWS secret access key with permissions to manage resources."
    type = string
    default = ""
}
