resource "time_sleep" "wait_for_dns_link" {
  create_duration = "60s"

  triggers = {
    dns_zone_link_id = var.dns_zone_link_id
  }
}

resource "azurerm_mysql_flexible_server" "main" {
  name                = var.mysql_server_name
  resource_group_name = var.resource_group_name
  location            = var.location

  administrator_login    = var.admin_username
  administrator_password = var.admin_password

  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  sku_name = var.sku_name
  version  = "8.0.21"

  storage {
    size_gb = 20
  }

  # Azure auto-assigns the availability zone at creation time and will
  # reject any attempt to "change" it later, even if Terraform is just
  # re-asserting a value it already has. Since we never set zone
  # explicitly ourselves, tell Terraform to leave it alone after creation.
  lifecycle {
    ignore_changes = [zone]
  }

  # Azure's MySQL provisioning service occasionally checks for the private
  # DNS zone VNet link before it has fully propagated, even though the link
  # resource itself already reports "complete". The explicit time_sleep
  # above adds a real-world buffer so this race condition can't happen.
  depends_on = [time_sleep.wait_for_dns_link]
}

resource "azurerm_mysql_flexible_database" "main" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb3"
  collation           = "utf8mb3_general_ci"
}
