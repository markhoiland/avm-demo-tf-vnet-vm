# Generate a random password if one is not provided
resource "random_password" "vm_password" {
  count   = var.admin_password == null ? 1 : 0
  length  = 16
  special = true
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network using Azure Verified Module
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.1.4"

  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  name                          = var.vnet_name
  virtual_network_address_space = var.vnet_address_space

  subnets = {
    subnet1 = {
      name             = "subnet-vm"
      address_prefixes = var.subnet_address_prefixes
    }
  }

  tags = var.tags
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "nsg-${var.vm_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Public IP
resource "azurerm_public_ip" "main" {
  name                = "pip-${var.vm_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Virtual Machine using Azure Verified Module
module "vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "~> 0.15.0"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = var.vm_name

  # VM Configuration
  sku_size = var.vm_size
  zone     = null

  # Operating System
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Network Interface - simplified approach, let module create it
  network_interfaces = {
    network_interface_1 = {
      name = "nic-${var.vm_name}"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "internal"
          subnet_resource_id            = module.vnet.subnets["subnet1"].id
          private_ip_address_allocation = "Dynamic"
          public_ip_address_resource_id = azurerm_public_ip.main.id
        }
      }
    }
  }

  # Authentication
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password != null ? var.admin_password : random_password.vm_password[0].result
  disable_password_authentication = var.disable_password_authentication

  # SSH Key (if password authentication is disabled)
  admin_ssh_keys = var.disable_password_authentication && var.public_key != null ? [
    {
      public_key = var.public_key
      username   = var.admin_username
    }
  ] : []

  # OS Disk
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  tags = var.tags
}