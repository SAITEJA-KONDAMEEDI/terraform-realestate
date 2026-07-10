module "network" {
  source = "./modules/network"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  vnet_name                 = var.vnet_name
  vnet_address_space        = var.vnet_address_space
  app_subnet_address_prefix = var.app_subnet_address_prefix
  db_subnet_address_prefix  = var.db_subnet_address_prefix
  mysql_server_name         = var.mysql_server_name
}

module "vm" {
  source = "./modules/vm"

  resource_group_name = module.network.resource_group_name
  location            = module.network.location
  app_subnet_id       = module.network.app_subnet_id
  vm_name             = var.vm_name
  vm_size             = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
}

module "nsg" {
  source = "./modules/nsg"

  resource_group_name  = module.network.resource_group_name
  location             = module.network.location
  app_subnet_id        = module.network.app_subnet_id
  my_public_ip         = var.my_public_ip
  network_interface_id = module.vm.network_interface_id
}

module "database" {
  source = "./modules/database"

  resource_group_name = module.network.resource_group_name
  location            = module.network.location
  mysql_server_name   = var.mysql_server_name
  admin_username      = var.mysql_admin_username
  admin_password      = var.mysql_admin_password
  database_name       = var.mysql_database_name
  sku_name            = var.mysql_sku_name
  delegated_subnet_id = module.network.db_subnet_id
  private_dns_zone_id = module.network.mysql_private_dns_zone_id
  dns_zone_link_id    = module.network.mysql_dns_zone_link_id
}

module "app_deploy" {
  source = "./modules/app_deploy"

  vm_public_ip         = module.vm.public_ip_address
  vm_admin_username    = var.vm_admin_username
  vm_admin_password    = var.vm_admin_password
  app_files_path       = "${path.module}/app_files"
  mysql_fqdn           = module.database.fqdn
  mysql_admin_username = var.mysql_admin_username
  mysql_admin_password = var.mysql_admin_password
  mysql_database_name  = var.mysql_database_name
  vm_id                = module.vm.vm_id
  nic_association_id   = module.nsg.nic_association_id
}
