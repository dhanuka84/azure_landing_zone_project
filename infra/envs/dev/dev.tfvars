location            = "westeurope"
resource_group_name = "rg-dev-app-services"
hub_rg_name         = "rg-platform-connectivity"
hub_vnet_name       = "vnet-hub-weu"
firewall_private_ip = "<set-after-platform-deploy>"
tags = { env = "dev", owner = "platform" }
