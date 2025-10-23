variable "name" {
  type    = string
  default = "rt-default"
}
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "firewall_private_ip" { type = string }
variable "subnet_ids" {
  type    = list(string)
  default = []
}
variable "tags" {
  type    = map(string)
  default = {}
}