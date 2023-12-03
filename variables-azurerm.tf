variable "create_storage" {
  description = "Create Azure Blob storage for Terraform state."
  type        = bool
  default     = false
}

variable "append_random_string" {
  description = "Append random string."
  type        = bool
  default     = true
}

variable "tenantid" {
  description = "Service endpoint Tenant ID."
  type        = string
  default     = null
}

variable "subscription_id" {
  description = "Service endpoint Subscription ID."
  type        = string
  default     = null
}

variable "subscription_name" {
  description = "Service endpoint Subscription name."
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region for Azure Blob storage for Terraform state."
  type        = string
  default     = "Australia East"
}

variable "storage_rg_name" {
  description = "Azure storage resource group."
  type        = string
  default     = "rg-terraform-state-tf"
}

variable "storage_account_name" {
  description = "Azure storage account name."
  type        = string
  default     = "stterraformstate"
}

variable "storage_account_tier" {
  description = "Azure storage tier."
  type        = string
  default     = "Standard"
}

variable "storage_account_replication" {
  description = "Azure storage replication."
  type        = string
  default     = "LRS"
}

variable "storage_container_name" {
  description = "Azure storage container."
  type        = string
  default     = "tfstate"
}

variable "terraform_blob_key" {
  description = "The name of the Blob used to retrieve/store Terraform's State file inside the Storage Container."
  type        = string
  default     = "terraform.tfstate"
}