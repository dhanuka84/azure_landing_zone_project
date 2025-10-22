# Zero Trust Upgrade Pack (Tailored)

Adds:
- `infra/modules/identity` (UAMI)
- `infra/modules/nsg-baseline` (NSG baseline)
- `infra/platform/connectivity/bastion-nsg.tf` (Azure Bastion NSG)
- `infra/platform/connectivity/outputs.tf` (Firewall private IP)
- `infra/platform/connectivity/private-dns-links.tf` (DNS links)
- `infra/envs/prod/data-remote.tf` (read connectivity state)
- `infra/envs/prod/app-identity.tf` (UAMI + RBAC to KV/ACR)
- `infra/envs/prod/udr.tf` (egress via Firewall)
- `infra/platform/mg/policy/assignments.tf` (deny NIC public IPs; enforce tags)
- `infra/pipelines/azure-pipelines-oidc.yml` (OIDC-enabled pipeline)

> Ensure your `infra/modules/rbac` supports a `principal_id` input; if not, add it and coalesce with legacy `principal_object_id`.
> Replace placeholders like `module.kv.id`, `module.acr.id`, and correct backend values in `data-remote.tf`.
> Optionally enforce private DNS linking via Azure Policy (DeployIfNotExists) at MG scope.

## Order
1) connectivity, 2) mg policy, 3) env prod.
