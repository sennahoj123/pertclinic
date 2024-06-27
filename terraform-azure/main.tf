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

# Data block to reference existing public IPs
data "azurerm_public_ip" "existing_ips" {
  for_each = {
    vm1        = "vm1-ip",
    vm2        = "vm2-ip",
    production = "production-ip"
  }

  name                = each.value  # Assuming each.value is the name or IP address of the existing public IP
  resource_group_name = data.azurerm_resource_group.existing.name
}

# Network interfaces for VMs
resource "azurerm_network_interface" "az_ni" {
  for_each            = var.vm_map  # Assuming var.vm_map contains your VM configuration

  name                = "${each.value.name}-ni"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = data.azurerm_public_ip.existing_ips[each.key].id
  }
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "az_vm" {
  for_each = var.vm_map  # Assuming var.vm_map contains your VM configuration

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

  provisioner "local-exec" {
    command = "echo ${data.azurerm_public_ip.existing_ips[each.key].ip_address} >> public_ips.txt"
  }
}

# Output block to print public IP addresses
output "public_ip_addresses" {
  value = {
    for key, ip in data.azurerm_public_ip.existing_ips : key => ip.ip_address
  }
}
