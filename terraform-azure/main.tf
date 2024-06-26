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

# Data block to reference existing resource group
data "azurerm_resource_group" "existing" {
  name = "iede_adu-rg"
}

# Data block to reference existing virtual network
data "azurerm_virtual_network" "existing" {
  name                = "iede_adu-rg-vnet"
  resource_group_name = data.azurerm_resource_group.existing.name
}

# Data block to reference existing subnet
data "azurerm_subnet" "existing" {
  name                 = "iede_adu-rg-subnet"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = data.azurerm_virtual_network.existing.name
}

# Data block to reference existing network security group
data "azurerm_network_security_group" "existing" {
  name                = "iede_adu-rg-security"
  resource_group_name = data.azurerm_resource_group.existing.name
}

# Network interfaces for VMs
resource "azurerm_network_interface" "az_ni" {
  for_each            = var.vm_map

  name                = "${each.value.name}-ni"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing.id
    private_ip_address_allocation = "Dynamic"
    // No need to specify public_ip_address_id here since we're creating new public IPs
  }
}

# Virtual Machines
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

// Output block to display public IP addresses of the created resources
output "public_ip_addresses" {
  value = {
    for k, ni in azurerm_network_interface.az_ni : k => azurerm_public_ip.vm[k].ip_address
  }
}
