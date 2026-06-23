output "vm_id" {
  value = azurerm_linux_virtual_machine.main.id
}

output "public_ip_address" {
  value = azurerm_public_ip.vm.ip_address
}

output "network_interface_id" {
  value = azurerm_network_interface.vm.id
}
