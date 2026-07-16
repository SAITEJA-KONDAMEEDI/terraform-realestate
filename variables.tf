variable "subscription_id" {
  description = "Azure subscription ID to deploy into. Find it with: az account list --output table"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID for the service principal. From 'az ad sp create-for-rbac' output."
  type        = string
}

variable "client_id" {
  description = "Service principal appId. From 'az ad sp create-for-rbac' output."
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Service principal password. From 'az ad sp create-for-rbac' output. Shown only once when created - store it in terraform.tfvars only, never commit it."
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure region to deploy into"
  type        = string
  default     = "Japan East"
}

variable "resource_group_name" {
  description = "Name of the resource group (matches original: RealEstate-rg)"
  type        = string
  default     = "RealEstate-rg"
}

# --- Networking ---

variable "vnet_name" {
  type    = string
  default = "RealEstate-sai"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "app_subnet_address_prefix" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "db_subnet_address_prefix" {
  type    = list(string)
  default = ["10.0.2.0/24"]
}

variable "aks_subnet_address_prefix" {
  type    = list(string)
  default = ["10.0.3.0/24"]
}

# --- VM ---

variable "vm_name" {
  type    = string
  default = "sairealestatevm"
}

variable "vm_size" {
  description = "VM size. D2s_v5 is a non-burstable general-purpose size with more reliable regional availability than B-series."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "vm_admin_password" {
  description = "Password for the VM admin user. Set this in terraform.tfvars, never commit it."
  type        = string
  sensitive   = true
}

variable "my_public_ip" {
  description = "Your current public IP (CIDR, e.g. 203.0.113.45/32) allowed to SSH into the VM."
  type        = string
}

# --- Database ---

variable "mysql_server_name" {
  description = "Globally unique MySQL Flexible Server name"
  type        = string
  default     = "dbserversai001"
}

variable "mysql_admin_username" {
  type    = string
  default = "azsqladmin"
}

variable "mysql_admin_password" {
  description = "Password for the MySQL admin user. Set this in terraform.tfvars, never commit it."
  type        = string
  sensitive   = true
}

variable "mysql_database_name" {
  type    = string
  default = "real_estate"
}

variable "mysql_sku_name" {
  description = "MySQL Flexible Server SKU (Burstable, cheapest tier)"
  type        = string
  default     = "B_Standard_B1ms"
}