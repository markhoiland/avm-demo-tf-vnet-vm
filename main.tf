locals {
  rg_name                    = "rg-${var.name_prefix}"
  nat_gateway_name           = "natgw-${var.name_prefix}"
  nat_gateway_public_ip_name = "natgw-pip-${var.name_prefix}"
  vnet_name                  = "vnet-${var.name_prefix}"
  vm_subnet_name             = "subnet-vm-${var.name_prefix}"
  bastion_name               = "bastion-${var.name_prefix}"
  key_vault_name             = "kv-${var.name_prefix}-${random_string.name_suffix.result}"
}

data "azurerm_client_config" "current" {}

resource "random_string" "name_suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
}

module "natgateway" {
  source  = "Azure/avm-res-network-natgateway/azurerm"
  version = "0.2.1"

  name                = local.nat_gateway_name
  enable_telemetry    = var.enable_telemetry
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  public_ips = {
    public_ip_1 = {
      name = local.nat_gateway_public_ip_name
    }
  }
}

module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"

  name                = local.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/20"]

  subnets = {
    vm_subnet_1 = {
      name           = local.vm_subnet_name
      address_prefixes = ["10.0.1.0/24"]
      nat_gateway = {
        id = module.natgateway.resource_id
      }
    }
    AzureBastionSubnet = {
      name           = "AzureBastionSubnet"
      address_prefixes = ["10.0.3.0/24"]
    }
  }
}

module "avm_res_keyvault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.9.1"

  name                        = local.key_vault_name
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  network_acls = {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  role_assignments = {
    deployment_user_secrets = {
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azurerm_client_config.current.object_id
    }
    }

    wait_for_rbac_before_secret_operations = {
      create = "60s"
  }
}

module "azure_bastion" {
  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "0.5.0"

  count = var.deploy_bastion ? 1 : 0

  name                = local.bastion_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration = {
    subnet_id = module.vnet.subnets["AzureBastionSubnet"].resource_id
  }
}

module "testvm" {
  for_each = var.virtual_machines_count

  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.18.1"

  enable_telemetry    = var.enable_telemetry
  name                = each.value.name
  sku_size            = each.value.size
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  zone                = each.value.zone

  generated_secrets_key_vault_secret_config = {
    key_vault_resource_id = module.avm_res_keyvault.resource_id
  }

  network_interfaces = {
    network_interface_1 = {
      name = "${each.value.name}-nic1"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "${each.value.name}-ipconfig1"
          private_ip_subnet_resource_id = module.vnet.subnets["vm_subnet_1"].resource_id
        }
      }
    }
  }

  depends_on = [module.avm_res_keyvault]
}