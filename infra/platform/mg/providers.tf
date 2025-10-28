terraform {
  required_version = "~> 1.13" # Use latest Terraform CLI

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.50" # <-- UPDATED AzureRM provider version
    }
  }
  /*  backend "azurerm" {}
  */

}

provider "azurerm" {
  features {}
  use_oidc = true # Enable OIDC for credential-less auth
}