resource "random_string" "random" {
  length  = 15
  special = false
  lower   = true
  numeric = true
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
  quota                = 1
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
  path             = azurerm_storage_share_directory.config.name
  storage_share_id = azurerm_storage_share.palo_bootstrap_share.id
  source           = "${path.module}/bootstrap/init-cfg.txt"
}


locals {
  bootstrap_xml_generated = templatefile("${path.module}/bootstrap/bootstrap.xml", {
    palo_vm_name          = var.palo_vm_name
    trust_subnet_router   = cidrhost(var.trust_cidr, 1)
    untrust_subnet_router = cidrhost(var.untrust_cidr, 1)
  })
}

resource "local_file" "bootstrap_xml_generated" {
  content  = local.bootstrap_xml_generated
  filename = "${path.module}/bootstrap/bootstrap_xml_generated.xml"
}


resource "azurerm_storage_share_file" "bootstrap_xml" {
  name             = "bootstrap.xml"
  path             = azurerm_storage_share_directory.config.name
  storage_share_id = azurerm_storage_share.palo_bootstrap_share.id
  source           = local_file.bootstrap_xml_generated.filename
}