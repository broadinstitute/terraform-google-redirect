variable "certificates" {
  description = "A map of certificates to create"
  type        = map(list(string))
}

variable "dns_authorizations" {
  default     = {}
  description = "A map of DNS authorizations to use, with the key being the domain authorized"
  type        = map(any)
}

variable "name" {
  default     = null
  description = "The name to use for all resources created."
  nullable    = true
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.name)) || var.name == null
    error_message = "The name value must be a valid Google resource name, alphanumeric and dashes"
  }
}

variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "suffix" {
  description = "A suffix to append to all resource names"
  type        = string
}

variable "use_dns_authorizations" {
  default     = true
  description = "Whether to use DNS authorizations for hostname verification"
  type        = bool
}
