# Azure Verified Modules (AVM) Demo - Virtual Network and Virtual Machine

This repository demonstrates how to use Azure Verified Modules (AVM) with Terraform to deploy a Virtual Network (VNet) and Virtual Machine (VM) on Microsoft Azure.

## Overview

This Terraform configuration creates:

- **Resource Group**: Container for all resources
- **Virtual Network**: Using the AVM Virtual Network module
- **Subnet**: For VM placement
- **Network Security Group**: Basic security rules for SSH and HTTP
- **Public IP**: For internet access to the VM
- **Network Interface**: Connects VM to the subnet
- **Virtual Machine**: Using the AVM Virtual Machine module with Ubuntu 22.04

## Azure Verified Modules Used

- [AVM Virtual Network](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest): `Azure/avm-res-network-virtualnetwork/azurerm`
- [AVM Virtual Machine](https://registry.terraform.io/modules/Azure/avm-res-compute-virtualmachine/azurerm/latest): `Azure/avm-res-compute-virtualmachine/azurerm`

## Prerequisites

1. **Azure CLI**: [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Terraform**: [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (>= 1.0)
3. **Azure Subscription**: Active Azure subscription with appropriate permissions

## Quick Start

### 1. Authentication

Login to Azure:
```bash
az login
```

Set your subscription (if you have multiple):
```bash
az account set --subscription "your-subscription-id"
```

### 2. Configuration

Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` to customize your deployment:
```hcl
location            = "East US"
resource_group_name = "rg-avm-demo"
vm_name            = "vm-avm-demo"
admin_username     = "azureuser"
admin_password     = "YourSecurePassword123!"
```

### 3. Deployment

Initialize Terraform:
```bash
terraform init
```

Plan the deployment:
```bash
terraform plan
```

Apply the configuration:
```bash
terraform apply
```

### 4. Connect to VM

After deployment, you can connect to the VM using SSH:
```bash
# Get the public IP from outputs
terraform output public_ip_address

# Connect via SSH
ssh azureuser@<public-ip>
```

## Configuration Options

### Authentication Methods

**Option 1: Password Authentication (Default)**
```hcl
admin_username = "azureuser"
admin_password = "YourSecurePassword123!"
disable_password_authentication = false
```

**Option 2: SSH Key Authentication (Recommended)**
```hcl
admin_username = "azureuser"
disable_password_authentication = true
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAA... your-public-key-here"
```

### VM Sizes

Common VM sizes for different use cases:
- `Standard_B1s` - 1 vCPU, 1 GB RAM (Basic)
- `Standard_B2s` - 2 vCPUs, 4 GB RAM (Default)
- `Standard_D2s_v3` - 2 vCPUs, 8 GB RAM (General Purpose)

### Network Configuration

Customize network settings:
```hcl
vnet_address_space      = ["10.0.0.0/16"]
subnet_address_prefixes = ["10.0.1.0/24"]
```

## Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `location` | Azure region for resources | `string` | `"East US"` |
| `resource_group_name` | Name of the resource group | `string` | `"rg-avm-demo"` |
| `vnet_name` | Name of the virtual network | `string` | `"vnet-avm-demo"` |
| `vnet_address_space` | Address space for VNet | `list(string)` | `["10.0.0.0/16"]` |
| `subnet_address_prefixes` | Address prefixes for subnet | `list(string)` | `["10.0.1.0/24"]` |
| `vm_name` | Name of the virtual machine | `string` | `"vm-avm-demo"` |
| `vm_size` | Size of the virtual machine | `string` | `"Standard_B2s"` |
| `admin_username` | Admin username for VM | `string` | `"azureuser"` |
| `admin_password` | Admin password for VM | `string` | `null` |
| `disable_password_authentication` | Disable password auth? | `bool` | `false` |
| `public_key` | SSH public key | `string` | `null` |
| `tags` | Tags for all resources | `map(string)` | See variables.tf |

## Outputs

| Output | Description |
|--------|-------------|
| `resource_group_name` | Name of the resource group |
| `virtual_network_name` | Name of the virtual network |
| `virtual_machine_name` | Name of the virtual machine |
| `public_ip_address` | Public IP address of the VM |
| `private_ip_address` | Private IP address of the VM |
| `ssh_connection_command` | SSH command to connect to VM |

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Security Considerations

- The default configuration allows SSH (port 22) and HTTP (port 80) from any source
- Consider restricting source IP ranges in production
- Use SSH key authentication instead of passwords when possible
- Review and customize the Network Security Group rules for your needs

## Troubleshooting

### Common Issues

1. **Authentication errors**: Ensure you're logged in with `az login`
2. **Permission errors**: Verify you have Contributor access to the subscription
3. **Resource conflicts**: Check if resource names already exist
4. **VM size availability**: Some VM sizes may not be available in all regions

### Useful Commands

```bash
# Check Terraform version
terraform version

# Validate configuration
terraform validate

# Format configuration files
terraform fmt

# Show current state
terraform show

# List resources
terraform state list
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the configuration
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## References

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Azure Virtual Machines Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
