
variable "region" {
  description = "The region in which the resources will be created."
  default     = "europe-west1"
}


variable "enable_uc_1" {
  description = "Enable Use Case 1 - Unauthorized Bucket Access"
  default     = true
}

variable "enable_uc_2" {
  description = "Enable Use Case 2 - Malicious Assume Service Account"
  default     = true
}

variable "uc2_config" {
  description = "Configuration for Use Case 2"

  default = {}

  type = object({
    role_title       = optional(string, "Organization Admin")
    role_description = optional(string, "Full access to all organization resources, including administrative tasks, financial data, and sensitive services. Be cautious with its usage.")
    permissions      = optional(list(string), ["storage.buckets.list"])
  })
}


variable "prefix" {
  description = "The prefix to be used for all resources not belonging to a specific usecase."
  default     = "engodo"
}

variable "decoys_prefix" {
  description = "The prefix to be used for all resources belonging to a specific usecase."
  default     = "mgmt"
}
