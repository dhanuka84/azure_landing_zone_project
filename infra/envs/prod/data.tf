# File: infra/envs/prod/data.tf (or append to data-remote.tf)

data "terraform_remote_state" "platform_connectivity" {
  backend = "azurerm"
  config = {
    #IMPORTANT: Replace these placeholder values with your actual tfstate backend details
    resource_group_name  = "rg-platform-tfstate" 
    storage_account_name = "saterraformstate001" 
    container_name       = "tfstate"             
    key                  = "platform/connectivity/terraform.tfstate" # Assumed state path
  }
}