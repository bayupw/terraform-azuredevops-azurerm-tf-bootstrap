resource "azurerm_resource_group" "this" {
  name     = "rg-tf-dev-001"
  location = "Australia East"
}

resource "azurerm_network_security_group" "this" {
  name                = "TestSecurityGroup1"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "devInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_virtual_network" "this" {
  name                = "dev-network"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.this.id
  }

  tags = {
    environment = "Dev"
  }
}