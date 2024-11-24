variable "env" {
  description = "dev | staging | prod = acronym of the environment to be created. This is required to uniquely identify global resources or configure TFC organizations and AWS accounts."
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS Region to host cloud resources."
  type        = string
  default     = null
}

variable "service_name" {
  description = "The name of the Ingress Service (API name)."
  type        = string
  default     = null # "moviesbackend"
}

variable "config_env" {
  description = "The name of the config section for the Flask configuration."
  type        = string
  default     = null # "moviesbackend.config.TestingConfig"
}

variable "workers" {
  description = "Number of the gunicorn web server's workers/threads."
  type        = string
  default     = null # "2"
}

variable "container_port" {
  description = "The port used by the docker container."
  type        = string
  default     = null # "80"
}