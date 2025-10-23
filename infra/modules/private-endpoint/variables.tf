variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "subnet_id" { type = string }
variable "target_resource_id" { type = string }
variable "subresource_names" { type = list(string) }
variable "private_dns_zone_id" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}