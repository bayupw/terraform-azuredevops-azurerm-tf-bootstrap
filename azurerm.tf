resource "random_string" "this" {
  count = var.append_random_string ? 1 : 0

  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "this" {
  count = var.create_storage ? 1 : 0

  name     = var.storage_rg_name
  location = var.location
}

resource "azurerm_storage_account" "this" {
  count = var.create_storage ? 1 : 0

  name                            = "${var.storage_account_name}${random_string.this[0].result}"
  resource_group_name             = azurerm_resource_group.this[0].name
  location                        = azurerm_resource_group.this[0].location
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication
  allow_nested_items_to_be_public = false

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_container" "this" {
  count = var.create_storage ? 1 : 0

  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.this[0].name
  container_access_type = "private"
}