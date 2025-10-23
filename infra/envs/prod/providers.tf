# File: infra/envs/prod/providers.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  # This resolves the HCL syntax error: Argument definition required
  features {}
  # The provider will now default to authentication via Azure CLI/Environment variables.
}