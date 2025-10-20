variable "name"                { type = string, default = "afw-hub" }
variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "subnet_id"           { type = string } # AzureFirewallSubnet ID
variable "public_ip_name"      { type = string, default = "pip-afw-hub" }
variable "sku_tier"            { type = string, default = "Standard" } # or Premium
variable "tags" { type = map(string), default = {} }
