variable "assignments" {
  type = list(object({
    scope_id           = string
    role_definition    = string
    principal_objectId = string
  }))
}
