variable "location" {
  description = "The Azure region to deploy resources in."
  type        = string
  default     = "Central US"

}

variable "name_prefix" {
  description = "Prefix for naming resources."
  type        = string
  default     = "tftesting"
}

variable "virtual_machines_count" {
  description = "Number of virtual machines to create."
  type = map(object({
    name  = string
    size  = string
    image = string
    zone  = optional(string, "1")
  }))
}

variable "deploy_bastion" {
  description = "Whether to deploy an Azure Bastion host."
  type        = bool
  default     = false
}

variable "enable_telemetry" {
  description = "Enable telemetry for the deployment."
  type        = bool
  default     = true
}
