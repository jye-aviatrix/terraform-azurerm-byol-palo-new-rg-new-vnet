resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.region
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

resource "azurerm_public_ip" "mgmt_pip" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "${var.palo_vm_name}-mgmt-pip"
  allocation_method   = "Static"
  sku                 = "Basic"
  sku_tier            = "Regional"
}

resource "azurerm_public_ip" "untrust_pip" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "${var.palo_vm_name}-untrust-pip"
  allocation_method   = "Static"
  sku                 = "Basic"
  sku_tier            = "Regional"
}

resource "azurerm_network_interface" "mgmt" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "${var.palo_vm_name}-eth0"
  ip_configuration {
    name                          = "ipconfig-mgmt"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.mgmt.id
    public_ip_address_id          = azurerm_public_ip.mgmt_pip.id
  }
  enable_ip_forwarding = false
}

resource "azurerm_network_interface" "untrust" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "${var.palo_vm_name}-eth1"
  ip_configuration {
    name                          = "ipconfig-untrust"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.untrust.id
    public_ip_address_id          = azurerm_public_ip.untrust_pip.id
  }
  enable_ip_forwarding = true
}

resource "azurerm_network_interface" "trust" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "${var.palo_vm_name}-eth2"
  ip_configuration {
    name                          = "ipconfig-trust"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.trust.id
  }
  enable_ip_forwarding = true
}

resource "random_string" "random" {
  length  = 15
  special = false
  lower   = true
  numeric  = true
  upper   = false
}

resource "azurerm_storage_account" "palo_bootstrap" {
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  name                     = "bootstrap${random_string.random.id}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_storage_share" "palo_bootstrap_share" {
  name                 = "share"
  storage_account_name = azurerm_storage_account.palo_bootstrap.name
  quota = 1
}

resource "azurerm_storage_share_directory" "config" {
  name                 = "config"
  share_name           = azurerm_storage_share.palo_bootstrap_share.name
  storage_account_name = azurerm_storage_account.palo_bootstrap.name
}

resource "azurerm_storage_share_directory" "content" {
  name                 = "content"
  share_name           = azurerm_storage_share.palo_bootstrap_share.name
  storage_account_name = azurerm_storage_account.palo_bootstrap.name
}

resource "azurerm_storage_share_directory" "license" {
  name                 = "license"
  share_name           = azurerm_storage_share.palo_bootstrap_share.name
  storage_account_name = azurerm_storage_account.palo_bootstrap.name
}

resource "azurerm_storage_share_directory" "software" {
  name                 = "software"
  share_name           = azurerm_storage_share.palo_bootstrap_share.name
  storage_account_name = azurerm_storage_account.palo_bootstrap.name
}

resource "azurerm_storage_share_file" "init_cfg" {
  name             = "init-cfg.txt"
  path = azurerm_storage_share_directory.config.name
  storage_share_id = azurerm_storage_share.palo_bootstrap_share.id
  source           = "./bootstrap/init-cfg.txt"
}