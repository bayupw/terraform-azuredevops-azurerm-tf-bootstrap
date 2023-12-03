terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.82.0"
    }
  }
  backend "azurerm" {
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}