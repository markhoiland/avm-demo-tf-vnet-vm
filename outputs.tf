output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = var.vnet_name
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = module.vnet.virtual_network_id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = module.vnet.subnets["subnet1"].id
}

output "virtual_machine_name" {
  description = "The name of the virtual machine"
  value       = var.vm_name
}

output "virtual_machine_id" {
  description = "The ID of the virtual machine"
  value       = module.vm.resource_id
}

output "public_ip_address" {
  description = "The public IP address of the virtual machine"
  value       = azurerm_public_ip.main.ip_address
}

output "admin_username" {
  description = "The admin username for the virtual machine"
  value       = var.admin_username
}

output "admin_password" {
  description = "The admin password for the virtual machine (only shown if generated)"
  value       = var.admin_password == null ? random_password.vm_password[0].result : null
  sensitive   = true
}

output "ssh_connection_command" {
  description = "SSH command to connect to the virtual machine"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}