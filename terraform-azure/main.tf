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
  name                 = "iede_adu-rg-subnet"
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = data.azurerm_resource_group.existing.name
}

data "azurerm_network_security_group" "existing" {
  name                = "iede_adu-rg-security"
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_public_ip" "existing" {
  for_each = var.vm_map

  name                = "${each.key}-ip"
  resource_group_name = data.azurerm_resource_group.existing.name
}

resource "azurerm_network_interface" "az_ni" {
  for_each            = var.vm_map

  name                = "${each.key}-ni"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.az_sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = data.azurerm_public_ip.existing[each.key].id
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
  value = {
    for key, public_ip in data.azurerm_public_ip.existing : key => public_ip.ip_address
  }
}
