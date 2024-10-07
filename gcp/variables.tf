
variable "region" {
  description = "The region in which the resources will be created."
  default     = "europe-west1"
  type        = string
}


variable "uc1_config" {

  description = "Configuration for Use Case 1 - Unauthorized Bucket Access"

  default = {}

  type = object({
    enable               = optional(bool, true)
    bucket_name          = optional(string, "") # if empty, a random name will be generated
    enable_audit_logging = optional(bool, true) # enable `ADMIN_READ`, `DATA_READ`, `DATA_WRITE` logs for cloud storage
    allowed_domains      = optional(list(string), null)
  })
}


variable "uc2_config" {
  description = "Configuration for Use Case 2 - Malicious Assume Service Account"

  default = {}

  type = object({
    enable               = optional(bool, true)
    role_title           = optional(string, "Organization Admin")
    role_description     = optional(string, "Full access to all organization resources, including administrative tasks, financial data, and sensitive services. Be cautious with its usage.")
    role_permissions     = optional(list(string), ["storage.buckets.list"])
    sa_name              = optional(string, "devops mgmt pipeline")
    enable_audit_logging = optional(bool, true) # enable `ADMIN_READ`, `DATA_READ`, `DATA_WRITE` logs for iam
    allowed_domains      = optional(list(string), [])
  })
}


variable "uc3_config" {
  description = "Configuration for Use Case 3 - Unauthorized Secret Store Access"

  default = {}

  type = object({
    enable               = optional(bool, true)
    secret_id            = optional(string, "Github Organization Token")
    secret_content       = optional(string, "") # if empty, a random content will be generated
    enable_audit_logging = optional(bool, true) # enable `ADMIN_READ`, `DATA_READ`, `DATA_WRITE` logs for secret manager
  })
}


variable "allowed_domains" {
  description = "List of domains that should be allowed to access the resources."
  default     = []
  type        = list(string)
}

variable "prefix" {
  description = "The prefix to be used for all resources not belonging to a specific usecase."
  default     = "engodo"
  type        = string
}

variable "organization_domain_id" {
  description = "The id domain of the organization."
  type        = string
}

variable "whitelist_service_accounts" {
  description = "List of service accounts that should be whitelisted."
  default     = []
  type        = list(string)
}
