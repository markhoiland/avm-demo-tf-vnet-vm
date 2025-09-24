terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  required_version = ">= 1.9.0"
}

provider "azurerm" {
  features {}

  # subscription_id = "" # Enter your subscription ID here if not using the default, as required in the azurerm provider > 4.0
}