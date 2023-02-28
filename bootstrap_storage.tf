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
  count = var.palo_vm_count
  name                 = local.bootstrap_share_name[count.index]
  storage_account_name = azurerm_storage_account.palo_bootstrap.name
  quota                = 1
}

resource "azurerm_storage_share_directory" "config" {
  count = var.palo_vm_count
  name                 = "config"
  share_name           = azurerm_storage_share.palo_bootstrap_share[count.index].name
  storage_account_name = azurerm_storage_account.palo_bootstrap.name
}

resource "azurerm_storage_share_directory" "content" {
  count = var.palo_vm_count
  name                 = "content"
  share_name           = azurerm_storage_share.palo_bootstrap_share[count.index].name
  storage_account_name = azurerm_storage_account.palo_bootstrap.name
}

resource "azurerm_storage_share_directory" "license" {
  count = var.palo_vm_count
  name                 = "license"
  share_name           = azurerm_storage_share.palo_bootstrap_share[count.index].name
  storage_account_name = azurerm_storage_account.palo_bootstrap.name
}

resource "azurerm_storage_share_directory" "software" {
  count = var.palo_vm_count
  name                 = "software"
  share_name           = azurerm_storage_share.palo_bootstrap_share[count.index].name
  storage_account_name = azurerm_storage_account.palo_bootstrap.name
}

resource "azurerm_storage_share_file" "init_cfg" {
  count = var.palo_vm_count
  name             = "init-cfg.txt"
  path             = azurerm_storage_share_directory.config[count.index].name
  storage_share_id = azurerm_storage_share.palo_bootstrap_share[count.index].id
  source           = "${path.module}/bootstrap/init-cfg.txt"
}


locals {
  # bootstrap_xml_generated = templatefile("${path.module}/bootstrap/bootstrap.xml", {
  #   palo_vm_name          = var.palo_vm_name
  #   trust_subnet_router   = cidrhost(var.trust_cidr, 1)
  #   untrust_subnet_router = cidrhost(var.untrust_cidr, 1)
  # })
  bootstrap_xml_filepath = [for idx in range(var.palo_vm_count) : "${path.module}/bootstrap/bootstrap.xml.${var.palo_vm_name}-${idx + 1}"]
  bootstrap_share_name = [for idx in range(var.palo_vm_count) : "${var.palo_vm_name}-${idx + 1}"]
}

resource "local_file" "bootstrap_xml_generated" {
  count = var.palo_vm_count
  content  = templatefile("${path.module}/bootstrap/bootstrap.xml", {
    palo_vm_name          = "${var.palo_vm_name}-${count.index+1}"
    trust_subnet_router   = cidrhost(var.trust_cidr, 1)
    untrust_subnet_router = cidrhost(var.untrust_cidr, 1)
  })
  filename = local.bootstrap_xml_filepath[count.index]
}


resource "azurerm_storage_share_file" "bootstrap_xml" {
  count = var.palo_vm_count
  name             = "bootstrap.xml"
  path             = azurerm_storage_share_directory.config[count.index].name
  storage_share_id = azurerm_storage_share.palo_bootstrap_share[count.index].id
  source           = local_file.bootstrap_xml_generated[count.index].filename
}