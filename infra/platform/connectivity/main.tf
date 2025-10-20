module "hub" {
  source              = "../../modules/networking-hub"
  name_prefix         = var.name_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
  firewall_cidr       = "10.0.0.0/24"
  gateway_cidr        = "10.0.1.0/24"
  bastion_cidr        = "10.0.2.0/24"
  create_private_dns  = true
}
