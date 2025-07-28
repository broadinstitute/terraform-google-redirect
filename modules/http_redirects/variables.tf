variable "certificates" {
  description = "A map of certificates to create"
  type        = map(list(string))
}

variable "default_destination_host" {
  description = "The default host to redirect to if no paths are matched"
  type        = string
}

variable "default_destination_path" {
  description = "The default path to redirect to if no paths are matched"
  type        = string
}

variable "default_redirect_response_code" {
  default     = "MOVED_PERMANENTLY_DEFAULT"
  description = "The default response code to use for redirects"
  type        = string
}

variable "dns_authorizations" {
  default     = {}
  description = "A map of DNS authorizations to use, with the key being the domain authorized"
  type        = map(any)
}

variable "http_port_range" {
  default     = "80"
  description = "A range of HTTP ports on which to listen"
  type        = string
}

variable "https_port_range" {
  default     = "443"
  description = "A range of HTTPS ports on which to listen"
  type        = string
}

variable "name" {
  description = "The name to use for all resources created"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.name))
    error_message = "The name value must be a valid Google resource name, alphanumeric and dashes"
  }
}

variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "redirects" {
  description = "The map of redirects to apply to the path under the hostname"
  type = list(object({
    destination_host       = string
    destination_path       = string
    redirect_response_code = optional(string, "MOVED_PERMANENTLY_DEFAULT")
    source_paths           = list(string)
  }))
}

variable "ssl_policy" {
  default     = null
  description = "The SSL policy to use for the redirects"
  type        = string
}

variable "use_dns_authorizations" {
  default     = true
  description = "Whether to use DNS authorizations for hostname verification"
  type        = bool
}
