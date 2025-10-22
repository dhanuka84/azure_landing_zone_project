variable "principal_id" {
  description = "Preferred: Entra principalId (e.g., UAMI principal_id)"
  type        = string
  default     = null
}

variable "principal_object_id" {
  description = "Legacy objectId input (for back-compat). If both are set, principal_id wins."
  type        = string
  default     = null
}

variable "scope_id" {
  description = "Scope for the role assignment (subscription/RG/resource)"
  type        = string
}

variable "role_definition_name" {
  description = "Built-in or custom role name (e.g., 'AcrPull')"
  type        = string
}
