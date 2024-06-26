provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "existing" {
  name     = "iede_adu-rg"
  location = "West Europe"  # Replace with the actual location of your resource group
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.existing.location
  resource_group_name = azurerm_resource_group.existing.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "vm1-nic" {
  name                      = "vm1-nic"
  location                  = azurerm_resource_group.existing.location
  resource_group_name       = azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "vm2-nic" {
  name                      = "vm2-nic"
  location                  = azurerm_resource_group.existing.location
  resource_group_name       = azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "production-nic" {
  name                      = "production-nic"
  location                  = azurerm_resource_group.existing.location
  resource_group_name       = azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "VM1"
  resource_group_name = azurerm_resource_group.existing.name
  location            = azurerm_resource_group.existing.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"  # Replace with your desired admin username
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your SSH public key
  }
  network_interface_ids = [azurerm_network_interface.vm1-nic.id]
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

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "VM2"
  resource_group_name = azurerm_resource_group.existing.name
  location            = azurerm_resource_group.existing.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"  # Replace with your desired admin username
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your SSH public key
  }
  network_interface_ids = [azurerm_network_interface.vm2-nic.id]
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

resource "azurerm_linux_virtual_machine" "production" {
  name                = "Production"
  resource_group_name = azurerm_resource_group.existing.name
  location            = azurerm_resource_group.existing.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"  # Replace with your desired admin username
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your SSH public key
  }
  network_interface_ids = [azurerm_network_interface.production-nic.id]
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

output "vm_public_ips" {
  value = {
    VM1        = azurerm_linux_virtual_machine.vm1.public_ip_address
    VM2        = azurerm_linux_virtual_machine.vm2.public_ip_address
    Production = azurerm_linux_virtual_machine.production.public_ip_address
  }
  json = true
}
