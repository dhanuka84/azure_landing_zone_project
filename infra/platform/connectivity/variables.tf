
variable "location"    { type = string }
variable "resource_group_name" { type = string }

variable "prefix" {
  type        = string
  description = "Global naming prefix"
}

variable "name_prefix" {
  type        = string
  description = "Global naming prefix"
}

variable "tags" {
  type    = map(string)
  default = {}
}
