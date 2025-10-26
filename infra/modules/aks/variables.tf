variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "dns_prefix" { type = string }
variable "subnet_id" { type = string }
variable "node_count" {
  type    = number
  default = 3
}
variable "vm_size" {
  type    = string
  default = "Standard_DS3_v2"
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "user_assigned_identity_id" {
  type        = string
  description = "The resource ID of the User-Assigned Managed Identity to use for the cluster."
  default     = null
}