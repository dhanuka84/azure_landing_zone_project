data "azurerm_client_config" "current" {}

# This remote state is crucial for getting Hub outputs (Firewall IP, DNS Zones)
data "terraform_remote_state" "platform_connectivity" {
  backend = "azurerm"
  config = {
    # These values MUST match your AzDO Variable Group (vg-terraform)
    resource_group_name  = "rg-tfstate"      # From $(TF_STATE_RG)
    storage_account_name = "saterraformstate123" # From $(TF_STATE_SA)
    container_name       = "tfstate"           # From $(TF_STATE_CONTAINER)
    key                  = "connectivity.tfstate"  # From $(TF_STATE_KEY_CONNECTIVITY)
  }
}