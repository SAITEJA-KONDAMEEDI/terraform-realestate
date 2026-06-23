variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "app_subnet_id" {
  type = string
}

variable "my_public_ip" {
  description = "CIDR allowed to SSH, e.g. 203.0.113.45/32"
  type        = string
}

variable "network_interface_id" {
  description = "NIC of the VM to attach this NSG to directly"
  type        = string
}
