variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed."
  default     = "East US"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create."
  default     = "rg-avm-demo"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network."
  default     = "vnet-avm-demo"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network."
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  type        = list(string)
  description = "Address prefixes for the subnet."
  default     = ["10.0.1.0/24"]
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine."
  default     = "vm-avm-demo"
}

variable "vm_size" {
  type        = string
  description = "Size of the virtual machine."
  default     = "Standard_B2s"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the virtual machine."
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  description = "Admin password for the virtual machine."
  sensitive   = true
  default     = null
}

variable "disable_password_authentication" {
  type        = bool
  description = "Should password authentication be disabled?"
  default     = false
}

variable "public_key" {
  type        = string
  description = "SSH public key for the virtual machine (required when password authentication is disabled)."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default = {
    Environment = "demo"
    Project     = "avm-demo"
  }
}