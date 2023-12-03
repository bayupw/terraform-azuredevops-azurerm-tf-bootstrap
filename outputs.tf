output "azuredevops_git_repository" {
  value = try(azuredevops_git_repository.this[0], null)
}

output "azuredevops_serviceendpoint_azurerm" {
  value = var.create_service_endpoint ? azuredevops_serviceendpoint_azurerm.this[0] : null
}

output "azurerm_resource_group" {
  value = var.create_storage ? azurerm_resource_group.this[0] : null
}

output "azurerm_storage_account" {
  value     = var.create_storage ? azurerm_storage_account.this[0] : null
  sensitive = true
}

output "azurerm_storage_container" {
  value = var.create_storage ? azurerm_storage_container.this[0] : null
}

output "azuredevops_variable_group" {
  value     = var.create_variables_group ? azuredevops_variable_group.this[0] : null
  sensitive = true
}