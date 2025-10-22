// Remote state read: adjust to your backend values
data "terraform_remote_state" "connectivity" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstates"
    storage_account_name = "saterraformstate123"
    container_name       = "tfstate"
    key                  = "platform_connectivity.tfstate"
  }
}
