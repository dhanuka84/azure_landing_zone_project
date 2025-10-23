variable "assignments" {
  type = map(object({
    scope              = string
    role_definition    = string
    principal_objectId = string
  }))
}
variable "tags" {
  type    = map(string)
  default = {}
}