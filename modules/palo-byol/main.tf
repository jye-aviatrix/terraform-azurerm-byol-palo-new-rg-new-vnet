
resource "azurerm_public_ip" "mgmt_pip" {
  resource_group_name = var.resource_group_name
  location            = var.region
  name                = "${var.palo_vm_name}-mgmt-pip"
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
  zones = var.zones
}

resource "azurerm_public_ip" "untrust_pip" {
  resource_group_name = var.resource_group_name
  location            = var.region
  name                = "${var.palo_vm_name}-untrust-pip"
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
  zones = var.zones
}

resource "azurerm_network_interface" "mgmt" {
  resource_group_name = var.resource_group_name
  location            = var.region
  name                = "${var.palo_vm_name}-eth0"
  ip_configuration {
    name                          = "ipconfig-mgmt"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.mgmt_subnet_id
    public_ip_address_id          = azurerm_public_ip.mgmt_pip.id
  }
  enable_ip_forwarding = false
}

resource "azurerm_network_interface" "untrust" {
  resource_group_name = var.resource_group_name
  location            = var.region
  name                = "${var.palo_vm_name}-eth1"
  ip_configuration {
    name                          = "ipconfig-untrust"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.untrust_subnet_id
    public_ip_address_id          = azurerm_public_ip.untrust_pip.id
  }
  enable_ip_forwarding = true
}

resource "azurerm_network_interface" "trust" {
  resource_group_name = var.resource_group_name
  location            = var.region
  name                = "${var.palo_vm_name}-eth2"
  ip_configuration {
    name                          = "ipconfig-trust"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.trust_subnet_id
  }
  enable_ip_forwarding = true
}




resource "azurerm_linux_virtual_machine" "palo_byol" {
  name                = var.palo_vm_name
  resource_group_name = var.resource_group_name
  location            = var.region
  size                = var.palo_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  zone                = var.zone

  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.mgmt.id,
    azurerm_network_interface.untrust.id,
    azurerm_network_interface.trust.id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries-flex"
    sku       = "byol"
    version   = var.palo_version
  }
  plan {
    name      = "byol"
    product   = "vmseries-flex"
    publisher = "paloaltonetworks"
  }
  custom_data = base64encode("storage-account=${var.storage_account},access-key=${var.access_key},file-share=${var.file_share},share-directory=")
}
