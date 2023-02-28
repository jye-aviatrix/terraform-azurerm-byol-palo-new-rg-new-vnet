output "mgmt_pip" {
  value = azurerm_public_ip.mgmt_pip.ip_address
}

output "palo_name" {
  value = var.palo_vm_name
}

output "trust_ip" {
  value = azurerm_network_interface.trust.private_ip_address
}
