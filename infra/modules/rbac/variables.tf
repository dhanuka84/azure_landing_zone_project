variable "assignments" {
  type = list(object({
    scope_id           = string
    role_definition    = string
    principal_objectId = string
  }))
}
variable "tags" { type = map(string), default = {} }
