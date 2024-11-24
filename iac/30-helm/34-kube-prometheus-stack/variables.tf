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

variable "admin_password" {
  description = "The admin password to authenticate in the Grafana deployed website."
  type        = string
  default     = null # 8L9xT6MCTGtmfSe
}