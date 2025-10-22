# Recommended Hardening Patch

This patch includes:
1) **RBAC module** update to support `principal_id` (preferred) with fallback to legacy `principal_object_id`.
   - Files: `infra/modules/rbac/variables.tf`, `infra/modules/rbac/main.tf`
2) **ACR module** hardened to default `public_network_access_enabled = false`.
   - Files: `infra/modules/acr/variables.tf`, `infra/modules/acr/main.tf`
3) **Key Vault module** hardened to default `public_network_access_enabled = false`, plus purge protection/soft delete best-practice.
   - Files: `infra/modules/keyvault/variables.tf`, `infra/modules/keyvault/main.tf`
4) **Spoke NSGs example** using your `nsg-baseline` module to attach NSGs to app/AKS subnets.
   - File: `infra/envs/prod/spoke-nsgs.tf` (replace TODOs with your actual subnet outputs)

## What it adds (drop-in under your repo root):

infra/modules/identity/ — User-Assigned Managed Identity (UAMI) module

infra/modules/nsg-baseline/ — reusable NSG + rules module

infra/platform/connectivity/bastion-nsg.tf — required AzureBastionSubnet NSG rules

infra/platform/connectivity/outputs.tf — exports Azure Firewall private IP

infra/platform/connectivity/private-dns-links.tf — example VNet link to Private DNS zones

infra/envs/prod/data-remote.tf — reads connectivity remote state (edit backend values)

infra/envs/prod/app-identity.tf — UAMI + RBAC to KV/ACR (replace placeholders with your module outputs)

infra/envs/prod/udr.tf — egress 0.0.0.0/0 via Firewall using your existing modules/udr

infra/platform/mg/policy/assignments.tf — MG-level guardrails (deny NIC public IPs; enforce tags)

infra/pipelines/azure-pipelines-oidc.yml — example pipeline using workload identity federation (keeps your original pipeline untouched)


## Quick setup checklist:

In infra/envs/prod/app-identity.tf, swap module.kv.id and module.acr.id for your actual module outputs.

Ensure infra/modules/rbac accepts a principal_id input; if not, add it and coalesce with any legacy principal_object_id.

Edit backend values in infra/envs/prod/data-remote.tf to point at your state storage.

Create an Entra workload-identity federated service connection in Azure DevOps named svc-conn-oidc and use infra/pipelines/azure-pipelines-oidc.yml.

(Optional) Add NSGs to other spokes via the nsg-baseline module and link Private DNS for all required zones or enforce via MG policy.

## How to apply
- Compare these files with your existing modules and **merge the changes** rather than a blind overwrite if you have additional attributes.
- In your ACR and Key Vault modules, ensure any existing features are preserved while adding the `public_network_access_enabled` variable and attribute defaulted to `false`.
- In `spoke-nsgs.tf`, replace placeholders (like `module.networking_spoke.app_subnet_id`) with the correct outputs or direct subnet IDs.
- Commit as a PR (e.g., `feat/hardening-patch`) and run a plan.
