variable "certificates" {
  description = "The list of certificates to create, with each element being a list of hostnames."
  type = map(list(string))
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
