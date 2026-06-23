output "nsg_id" {
  value = azurerm_network_security_group.main.id
}

output "nic_association_id" {
  description = "Used by app_deploy module to ensure SSH works before provisioners run"
  value       = azurerm_network_interface_security_group_association.vm.id
}
