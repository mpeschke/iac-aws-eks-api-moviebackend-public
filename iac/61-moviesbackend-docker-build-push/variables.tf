variable "env" {
  description = "dev | staging | prod = acronym of the environment to be created. This is required to uniquely identify global resources or configure TFC organizations and AWS accounts."
  type        = string
  default     = null
}

variable "docker_tag" {
  description = "The name of the tag for the Docker image."
  type        = string
  default     = null
}

variable "repository_branch" {
  description = "The git branch or tag that represents the docker tag."
  type        = string
  default     = null
}