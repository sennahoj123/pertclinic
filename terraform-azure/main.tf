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

resource "azurerm_virtual_network" "az_vn" {
  name                = "iede_adu-rg-vnet"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  address_space       = ["10.123.0.0/16"]
}

resource "azurerm_subnet" "az_sn" {
  name                 = "iede_adu-rg-subnet"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.az_vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "az_sg" {
  name                = "iede_adu-rg-security"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
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
  network_security_group_name = azurerm_network_security_group.az_sg.name 
}

resource "azurerm_subnet_network_security_group_association" "az_sn" {
  subnet_id                 = azurerm_subnet.az_sn.id
  network_security_group_id = azurerm_network_security_group.az_sg.id
}

resource "azurerm_public_ip" "az_ip" {
  name                = "iede_adu-rg-ip"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "az_ni" {
  name                = "iede_adu-rg-nic"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.az_sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.az_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "az_vm" {
  for_each = var.vm_map

  name                = "${each.value.name}"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.az_ni[each.key].id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa_ansible.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
