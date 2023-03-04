output "mgmt_pip" {
  value = azurerm_public_ip.mgmt_pip.ip_address
}


output "mgmt_url" {
  value = "https://${azurerm_public_ip.mgmt_pip.ip_address}"
}

output "palo_name" {
  value = var.palo_vm_name
}

output "admin_username__may_change_by_bootstrap" {
  value = var.admin_username
}

output "admin_password__may_change_by_bootstrap" {
  value = var.admin_password
}

output "trust_ip" {
  value = azurerm_network_interface.trust.private_ip_address
}
