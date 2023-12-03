resource "azuredevops_project" "this" {
  name               = var.project_name
  description        = var.project_description
  visibility         = var.project_visibility
  version_control    = var.project_version_control
  work_item_template = var.project_work_item_template
  features           = var.project_features
}

resource "azuredevops_serviceendpoint_azurerm" "this" {
  count = var.create_service_endpoint ? 1 : 0

  project_id                             = azuredevops_project.this.id
  service_endpoint_name                  = var.service_endpoint_name
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"
  description                            = var.service_endpoint_description
  azurerm_spn_tenantid                   = var.tenantid
  azurerm_subscription_id                = var.subscription_id
  azurerm_subscription_name              = var.subscription_name
}