provider "azuredevops" {
  org_service_url       = "${var.azuredevops_organisation_prefix}/${var.azuredevops_organisation}"
  personal_access_token = var.azuredevops_token
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}