terraform {
  backend "azurerm" {
    resource_group_name  = "RealEstate-rg"
    storage_account_name = "realestatetfstate123"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}