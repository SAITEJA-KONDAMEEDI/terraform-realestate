output "fqdn" {
  description = "MySQL Flexible Server hostname, reachable only from inside the VNet"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "server_name" {
  value = azurerm_mysql_flexible_server.main.name
}

output "database_name" {
  value = azurerm_mysql_flexible_database.main.name
}
