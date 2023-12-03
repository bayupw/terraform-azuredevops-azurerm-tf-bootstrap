terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.61.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.30.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.9.0"
    }
  }
}
