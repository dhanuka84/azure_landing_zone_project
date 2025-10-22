data "terraform_remote_state" "platform_connectivity" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-prod-tfstate"
    storage_account_name = "saprodstate123"
    container_name       = "tfstate"
    key                  = "platform_connectivity.tfstate"
  }
}