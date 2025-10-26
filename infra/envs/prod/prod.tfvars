location            = "westeurope"
resource_group_name = "rg-prod-app-services"
hub_rg_name         = "rg-platform-connectivity"
hub_vnet_name       = "vnet-hub-weu"
tags = { env = "prod", owner = "platform" }

# REMOVED: spn_app_cicd_prod      = "<objectId...>"
# REMOVED: spn_key_vault_api_prod = "<objectId...>"
# REMOVED: firewall_private_ip    = "<set...>" (This is now sourced from remote state)
# REMOVED: vnet_address_space and vnet_subnets (Now handled in main.tf locals)