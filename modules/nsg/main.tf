resource "azurerm_network_security_group" "main" {
  name                = "sainsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Attach the NSG to the App subnet (defence in depth)
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = var.app_subnet_id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Attach the NSG directly to the VM's NIC too.
# This is the step that was MISSING in the original manual deployment
# (doc Section 12.1) - the NSG existed but had 0 NICs attached, which is
# why SSH timed out. Terraform makes this association an explicit resource,
# so it can never silently be "forgotten" the way a portal click can.
resource "azurerm_network_interface_security_group_association" "vm" {
  network_interface_id      = var.network_interface_id
  network_security_group_id = azurerm_network_security_group.main.id
}
