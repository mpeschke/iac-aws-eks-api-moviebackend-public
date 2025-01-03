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

variable "wildcard_domain_name" {
  description = "A wildcard domain (or parent domain) to host multiple subdomains for different environments. Example of wildcard domain: mpeschke.org. Its subdomains: staging.mpeschke.org, dev.mpeschke.org, etc."
  type        = string
  default     = null
}
