variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "mysql_server_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "database_name" {
  type = string
}

variable "sku_name" {
  type = string
}

variable "delegated_subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}

variable "dns_zone_link_id" {
  description = "Forces correct ordering: DNS link must exist before the MySQL server"
  type        = string
}
