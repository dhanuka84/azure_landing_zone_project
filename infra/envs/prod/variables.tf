variable "location" {
  description = "Azure region for deployment"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

variable "tenant_id" {
  description = "Azure Active Directory Tenant ID"
  type        = string
}
