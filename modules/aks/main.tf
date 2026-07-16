resource "azurerm_kubernetes_cluster" "aks" {
  name                = "sai-realestate-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "saireal"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2as_v5"
    vnet_subnet_id = var.aks_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }
    network_profile {
  network_plugin = "azure"

  service_cidr   = "10.240.0.0/16"
  dns_service_ip = "10.240.0.10"
}


}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}