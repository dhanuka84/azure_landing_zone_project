resource "azurerm_management_group" "platform" { display_name = "Platform"   name = "platform" }
resource "azurerm_management_group" "nonprod"  { display_name = "NonProd"    name = "nonprod" }
resource "azurerm_management_group" "prod"     { display_name = "Production" name = "production" }
