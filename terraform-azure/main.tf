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

data "azurerm_subnet" "internal" {
  name                 = "iede_adu-rg-subnet"
  virtual_network_name = "iede_adu-rg-vnet"
  resource_group_name  = data.azurerm_resource_group.existing.name
}

data "azurerm_network_interface" "vm1-nic" {
  name                = "vm1-nic"
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_network_interface" "vm2-nic" {
  name                = "vm2-nic"
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_network_interface" "production-nic" {
  name                = "production-nic"
  resource_group_name = data.azurerm_resource_group.existing.name
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "VM1"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [
    data.azurerm_network_interface.vm1-nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "24_04-lts"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "VM2"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [
    data.azurerm_network_interface.vm2-nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "24_04-lts"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "production" {
  name                = "Production"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [
    data.azurerm_network_interface.production-nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "24_04-lts"
    version   = "latest"
  }
}

output "vm_public_ips" {
  value = {
    VM1        = azurerm_linux_virtual_machine.vm1.public_ip_address
    VM2        = azurerm_linux_virtual_machine.vm2.public_ip_address
    Production = azurerm_linux_virtual_machine.production.public_ip_address
  }
}
