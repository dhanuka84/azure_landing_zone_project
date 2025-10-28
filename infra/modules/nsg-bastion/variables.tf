variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to deploy into."
}

variable "subnet_id" {
  type        = string
  description = "The resource ID of the AzureBastionSubnet."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to apply to the NSG."
}

variable "prefix" { type = string }
