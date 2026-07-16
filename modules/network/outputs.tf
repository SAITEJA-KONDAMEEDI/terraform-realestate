output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "location" {
  value = azurerm_resource_group.main.location
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "app_subnet_id" {
  value = azurerm_subnet.app.id
}

output "db_subnet_id" {
  value = azurerm_subnet.db.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "mysql_private_dns_zone_id" {
  value = azurerm_private_dns_zone.mysql.id
}

output "mysql_dns_zone_link_id" {
  description = "Used elsewhere only to express a depends_on if needed"
  value       = azurerm_private_dns_zone_virtual_network_link.mysql.id
}