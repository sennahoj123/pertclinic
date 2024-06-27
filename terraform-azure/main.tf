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
data "azurerm_virtual_network" "existing_vn" {
  name                = "iede_adu-rg-vnet"
  resource_group_name = data.azurerm_resource_group.existing.name
}

# Data block to reference existing subnet
data "azurerm_subnet" "existing_subnet" {
  name                 = "iede_adu-rg-subnet"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = data.azurerm_virtual_network.existing_vn.name
}

# Data block to reference existing network security group
data "azurerm_network_security_group" "existing_sg" {
  name                = "iede_adu-rg-security"
  resource_group_name = data.azurerm_resource_group.existing.name
}

# Data block to reference existing public IP addresses
data "azurerm_public_ip" "existing_ip" {
  for_each            = var.vm_map

  name                = "${each.value.name}-ip"
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
    subnet_id                     = data.azurerm_subnet.existing_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = data.azurerm_public_ip.existing_ip[each.key].id
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
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = "echo ${data.azurerm_public_ip.existing_ip[each.key].ip_address} >> public_ips.txt"
  }
}

# Output block to print public IP addresses
output "public_ip_addresses" {
  value = { for k, v in data.azurerm_public_ip.existing_ip : k => v.ip_address }
}
