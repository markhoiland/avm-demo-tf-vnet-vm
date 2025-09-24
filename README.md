# Azure Verified Modules Demo - Virtual Network with Virtual Machines

This Terraform project demonstrates the use of Azure Verified Modules (AVM) to deploy a complete virtual network infrastructure with virtual machines in Azure. The deployment includes networking components, security features, and compute resources following Azure best practices.

## Architecture Overview

This deployment creates the following Azure resources using AVM modules:

- **Virtual Network**: A secure virtual network with subnets for VMs and Azure Bastion
- **NAT Gateway**: Provides outbound internet connectivity for virtual machines
- **Virtual Machines**: Configurable number of VMs deployed across availability zones
- **Key Vault**: Secure storage for VM credentials and secrets
- **Azure Bastion** (Optional): Secure RDP/SSH access to virtual machines
- **Resource Group**: Logical container for all resources

## Azure Verified Modules Used

| Module | Version | Purpose |
|--------|---------|---------|
| [avm-res-network-virtualnetwork](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm) | 0.8.1 | Virtual network and subnets |
| [avm-res-network-natgateway](https://registry.terraform.io/modules/Azure/avm-res-network-natgateway/azurerm) | 0.2.1 | NAT gateway for outbound connectivity |
| [avm-res-compute-virtualmachine](https://registry.terraform.io/modules/Azure/avm-res-compute-virtualmachine/azurerm) | 0.18.1 | Virtual machines |
| [avm-res-keyvault-vault](https://registry.terraform.io/modules/Azure/avm-res-keyvault-vault/azurerm) | 0.9.1 | Key Vault for secrets management |
| [avm-res-network-bastionhost](https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/azurerm) | 0.5.0 | Azure Bastion (optional) |

## Network Configuration

- **Virtual Network**: 10.0.0.0/20 address space
- **VM Subnet**: 10.0.1.0/24 (connected to NAT Gateway)
- **Bastion Subnet**: 10.0.3.0/24 (AzureBastionSubnet)

## Prerequisites

- **Terraform**: >= 1.9.0 ([Install Terraform](https://developer.hashicorp.com/terraform/install))
  ```powershell
  winget install Hashicorp.Terraform
  ```
- **Azure CLI**: Authenticated with appropriate permissions
- **Azure Subscription**: With contributor access

## Configuration

1. **Copy the example variables file**:
   ```powershell
   Copy-Item terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`** with your desired configuration:
   ```hcl
   location = "Central US"
   name_prefix = "tfdemo"
   virtual_machines_count = {
     vm1 = {
       name = "appvm1"
       size = "Standard_B1s"
       image = "UbuntuLTS"
       zone = "1"
     }
     vm2 = {
       name = "appvm2"
       size = "Standard_B1s"
       image = "UbuntuLTS"
       zone = "2"
     }
   }
   deploy_bastion = false
   ```

## Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `location` | string | "Central US" | Azure region for deployment |
| `name_prefix` | string | "tftesting" | Prefix for resource naming |
| `virtual_machines_count` | map(object) | - | Map of VMs to create with configuration |
| `deploy_bastion` | bool | false | Whether to deploy Azure Bastion |
| `enable_telemetry` | bool | true | Enable telemetry for AVM modules |

## Deployment

1. **Initialize Terraform**:
   ```powershell
   terraform init
   ```

2. **Validate configuration**:
   ```powershell
   terraform validate
   ```

3. **Plan deployment**:
   ```powershell
   terraform plan
   ```

4. **Apply configuration**:
   ```powershell
   terraform apply -auto-approve
   ```

## Security Features

- **Key Vault Integration**: VM passwords are automatically generated and stored in Azure Key Vault
- **NAT Gateway**: Provides secure outbound internet access without exposing VMs to inbound traffic
- **Azure Bastion** (Optional): Secure browser-based RDP/SSH access
- **Network Security**: VMs are deployed in a private subnet with no direct internet access

## Resource Naming Convention

Resources follow a consistent naming pattern:
- Resource Group: `rg-{name_prefix}`
- Virtual Network: `vnet-{name_prefix}`
- NAT Gateway: `natgw-{name_prefix}`
- Key Vault: `kv-{name_prefix}-{random_suffix}`
- Virtual Machines: As specified in `virtual_machines_count`

## Clean Up

To destroy all resources:
```powershell
terraform destroy
```

## Contributing

This project demonstrates Azure Verified Modules usage. For contributions:
1. Follow [Terraform style guide](https://developer.hashicorp.com/terraform/language/style)
2. Test changes in a development environment
3. Update documentation as needed

## References

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
