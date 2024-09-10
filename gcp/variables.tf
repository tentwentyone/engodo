
variable "region" {
  description = "The region in which the resources will be created."
  default     = "europe-west1"
}


variable "enable_uc_1" {
  description = "Enable UseCase 1 - Unauthorized Bucket Access"
  default     = true
}

variable "enable_uc_2" {
  description = "Enable UseCase 2 - Malicious Assume Role"
  default     = true
}


variable "prefix" {
  description = "The prefix to be used for all resources not belonging to a specific usecase."
  default     = "engodo"
}

variable "decoys_prefix" {
  description = "The prefix to be used for all resources belonging to a specific usecase."
  default     = "mgmt"
}
