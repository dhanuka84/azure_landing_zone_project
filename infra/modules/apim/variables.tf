variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "publisher_name" { type = string }
variable "publisher_email" { type = string }

variable "sku_name" {
  type        = string
  description = "The SKU for APIM. e.g., 'Developer_1' or 'Premium_1'."
  # Note: VNet integration requires Developer or Premium SKU
}

variable "vnet_type" {
  type        = string
  description = "Network type. 'Internal' or 'External'."
  default     = "Internal"
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID for APIM to join."
}

variable "tags" {
  type    = map(string)
  default = {}
}