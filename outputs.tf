# Resource Group Outputs
output "resource_group_name" {
  description = "The name of the resource group containing all resources"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "The resource ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "location" {
  description = "The Azure region where resources were deployed"
  value       = azurerm_resource_group.main.location
}