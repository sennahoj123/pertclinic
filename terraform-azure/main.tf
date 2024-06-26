terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "existing" {
  name = "iede_adu-rg"
}

data "azurerm_virtual_network" "existing" {
  name                = "iede_adu-rg-vnet"
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_subnet" "az_sn" {
  name                = "iede_adu-rg-subnet"
  virtual_network_name = "iede_adu-rg-vnet"
  resource_group_name = "iede_adu-rg"
}

data "azurerm_network_security_group" "existing" {
  name                = "iede_adu-rg-security"
  resource_group_name = "iede_adu-rg"
}

resource "azurerm_network_security_rule" "az_sr" {
  name                        = "iede_adu-rg-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.existing.name
  network_security_group_name = data.azurerm_network_security_group.existing.name
}

resource "azurerm_subnet_network_security_group_association" "az_sn" {
  subnet_id                 = azurerm_subnet.az_sn.id
  network_security_group_id = data.azurerm_network_security_group.existing.id
}

resource "azurerm_public_ip" "az_ip" {
  for_each = var.vm_map

  name                = "${each.value.name}-ip"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "az_ni" {
  for_each            = var.vm_map

  name                = "${each.value.name}-ni"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.az_sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.az_ip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "az_vm" {
  for_each = var.vm_map

  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.az_ni[each.key].id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/home/adminuser/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

output "public_ip_addresses" {
  value = { for k, v in azurerm_public_ip.az_ip : k => v.ip_address }
}
