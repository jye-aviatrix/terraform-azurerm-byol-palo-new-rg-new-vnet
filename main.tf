module "palo_byol" {
  source = "./modules/palo-byol"
  count = var.palo_vm_count
  region = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  palo_vm_name = "${var.palo_vm_name}-${count.index+1}"
  mgmt_subnet_id = azurerm_subnet.mgmt.id
  untrust_subnet_id = azurerm_subnet.untrust.id
  trust_subnet_id = azurerm_subnet.trust.id
  palo_size = var.palo_size
  palo_version = var.palo_version
  admin_username = var.admin_username
  admin_password = var.admin_password
  storage_account = azurerm_storage_account.palo_bootstrap.name
  access_key = azurerm_storage_account.palo_bootstrap.primary_access_key
  file_share = azurerm_storage_share.palo_bootstrap_share[count.index].name
}

output "palo_byol" {
  value = module.palo_byol[*]
}