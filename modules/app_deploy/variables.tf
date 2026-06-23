variable "vm_public_ip" {
  type = string
}

variable "vm_admin_username" {
  type = string
}

variable "vm_admin_password" {
  type      = string
  sensitive = true
}

variable "app_files_path" {
  description = "Local path to the folder containing app.py, database.py, index.py, requirements.txt, setup_vm.sh"
  type        = string
}

variable "mysql_fqdn" {
  type = string
}

variable "mysql_admin_username" {
  type = string
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true
}

variable "mysql_database_name" {
  type = string
}

variable "vm_id" {
  description = "Used only to trigger re-deploy when the VM is replaced"
  type        = string
}

variable "nic_association_id" {
  description = "Ensures the NSG is attached to the NIC (so SSH actually works) before provisioners run"
  type        = string
}
