resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.region
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}
resource "azurerm_virtual_network" "this" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = var.vnet_name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "mgmt" {
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  name                 = "Mgmt"
  address_prefixes     = [var.mgmt_cidr]
}

resource "azurerm_subnet" "untrust" {
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  name                 = "Untrust"
  address_prefixes     = [var.untrust_cidr]
}

resource "azurerm_subnet" "trust" {
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  name                 = "Trust"
  address_prefixes     = [var.trust_cidr]
}

resource "azurerm_network_security_group" "default_nsg" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "DefaultNSG"

  security_rule {
    access                     = "Deny"
    description                = "Default-Deny if we don't match Allow rule"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "Default-Deny"
    priority                   = 200
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    description                = "Allow intra network traffic"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "Allow-Intra"
    priority                   = 101
    protocol                   = "*"
    source_address_prefix      = var.vnet_cidr
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    description                = "Allow your egress IP access mgmt"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "Allow-Outside-From-IP"
    priority                   = 100
    protocol                   = "*"
    source_address_prefix      = "${data.http.ip.response_body}/32"
    source_port_range          = "*"
  }
}


resource "azurerm_subnet_network_security_group_association" "default_nsg_association" {
  subnet_id                 = azurerm_subnet.mgmt.id
  network_security_group_id = azurerm_network_security_group.default_nsg.id
}
