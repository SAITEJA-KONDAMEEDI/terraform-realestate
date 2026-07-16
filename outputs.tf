output "vm_public_ip" {
  description = "Public IP of the application VM - visit http://<this_ip> once deployed"
  value       = module.vm.public_ip_address
}

output "mysql_fqdn" {
  description = "MySQL Flexible Server hostname (private, reachable only from inside the VNet)"
  value       = module.database.fqdn
}

output "ssh_command" {
  description = "Command to SSH into the VM"
  value       = "ssh ${var.vm_admin_username}@${module.vm.public_ip_address}"
}

output "acr_login_server" {
  description = "ACR login server - use for docker tag/push, e.g. docker push <this>/realestate-app:v1"
  value       = module.acr.acr_login_server
}

output "aks_cluster_name" {
  description = "AKS cluster name - use with: az aks get-credentials --resource-group RealEstate-rg --name <this>"
  value       = module.aks.aks_name
}
}
