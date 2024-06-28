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

# Create new public IP addresses for VMs
resource "azurerm_public_ip" "az_ip" {
  for_each            = {
    vm1        = "vm1-ip",
    vm2        = "vm2-ip",
    production = "production-ip"
  }

  name                = each.value  # Use each.value for the friendly name
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
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
    public_ip_address_id          = azurerm_public_ip.az_ip[each.key].id
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
    public_key = file("/opt/pertclinic/ansible/ssh_key.pub")
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
    command = <<-EOT
      echo "Executing provisioner for ${each.key}"
      echo "Public IP Address: ${azurerm_public_ip.az_ip[each.key].ip_address}"
      echo "${azurerm_public_ip.az_ip[each.key].ip_address}" >> /opt/pertclinic/terraform-azure/public_ips.txt
    EOT

    working_dir = "/opt/pertclinic/terraform-azure"
  }
}

# Output block to print public IP addresses
output "public_ip_addresses" {
  value = {
    for key, ip in azurerm_public_ip.az_ip : key => ip.ip_address
  }
}
