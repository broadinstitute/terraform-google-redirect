variable "hostnames" {
  description = "A map of certificates to create, with the value being the list of hostnames"
  type        = list(string)
}

variable "default_destination_host" {
  description = "The default host to redirect to if no paths are matched."
  type        = string
}

variable "default_destination_path" {
  description = "The default path to redirect to if no paths are matched."
  type        = string
}

variable "name" {
  default     = null
  description = "The name to use for all resources created."
  nullable    = true
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.name)) || var.name == null
    error_message = "The name value must be a valid Google resource name, alphanumeric and dashes."
  }
}

variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "redirects" {
  description = "The map of redirects to apply to the path under the hostname."
  type = list(object({
    destination_host       = string
    destination_path       = string
    redirect_response_code = string
    source_paths           = list(string)
  }))
}

variable "ssl_policy" {
  default     = null
  description = "The SSL policy to use for the redirects."
  type        = string
}
