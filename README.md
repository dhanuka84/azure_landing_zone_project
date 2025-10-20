
# Hands-On Guide: Building a Production-Ready Azure Landing Zone with Terraform and Entra ID

In today’s cloud-native world, a well-architected landing zone is the bedrock of a secure, scalable, and well-governed Azure environment. 
In this guide, we’ll use a real, working repository — [azure_landing_zone_project](https://github.com/dhanuka84/azure_landing_zone_project) — 
to deploy a production-ready landing zone built with **Terraform**, automated through **Azure DevOps**, and governed by **Microsoft Entra ID**.

---

## 1. The Mental Model: What We’re Building

### Governance
- **Management Groups**: `Platform`, `Non-Production`, and `Production` — enforcing policies and compliance.

### Networking
- **Hub-and-Spoke Architecture**
  - **Hub VNet (`vnet-hub-weu`)**
    - `AzureFirewallSubnet`: hosts Azure Firewall (zone redundant)
    - `GatewaySubnet`: reserved for VPN/ExpressRoute Gateway
    - `AzureBastionSubnet`: secure RDP/SSH via Bastion
    - **Private DNS Zones**: for private endpoints (Key Vault, ACR)
  - **Spoke VNets** for `Dev`, `QA`, and `Prod` environments.

### Subscriptions
- `Connectivity` → Hub & shared resources  
- `Dev`, `QA`, `Prod` → Isolated workloads and billing separation

---

## 2. Identity and Security with Microsoft Entra ID

| Identity | Purpose | Access Scope |
|-----------|----------|--------------|
| `app-cicd-pipeline` | CI/CD automation | Contributor (Dev/QA), AKS Admin (Prod) |
| `app-backend-api` | Workload identity | Key Vault & ACR |
| `app-monitor` | Monitoring | Reader |

RBAC assignments via Terraform:
```hcl
module "rbac" {
  assignments = [
    {
      scope_id           = module.acr.id
      role_definition    = "AcrPush"
      principal_objectId = var.spn_app_cicd_prod
    },
    {
      scope_id           = module.kv.id
      role_definition    = "Key Vault Secrets User"
      principal_objectId = var.spn_key_vault_api_prod
    }
  ]
}
```

---

## 3. Project Structure

```
infra/
├─ modules/
│  ├─ networking-hub/
│  ├─ azure-firewall/
│  ├─ udr/
│  ├─ networking-spoke/
│  ├─ aks/ acr/ keyvault/ private-endpoint/ rbac/
│
├─ platform/
│  ├─ mg/
│  └─ connectivity/
│
├─ envs/
│  ├─ dev/ qa/ prod/
│
└─ pipelines/
   └─ azure-pipelines.yml
```

---

## 4. Step-by-Step Deployment

### Step 1 – Set Up Terraform Remote State

```bash
az group create -n rg-tfstate -l westeurope
az storage account create -n saterraformstate123 -g rg-tfstate   --sku Standard_LRS --encryption-services blob
az storage container create -n tfstate --account-name saterraformstate123
```

### Step 2 – Configure Azure DevOps

**Service Connections**
- `azrm-platform`: Hub subscription  
- `azrm-nonprod`: Dev + QA  
- `azrm-prod`: Production

**Variable Group `vg-terraform`**
```
TF_STATE_RG=rg-tfstate
TF_STATE_SA=saterraformstate123
TF_STATE_CONTAINER=tfstate
TF_STATE_KEY_PLATFORM_MG=platform_mg.tfstate
TF_STATE_KEY_CONNECTIVITY=connectivity.tfstate
TF_STATE_KEY_DEV=dev.tfstate
TF_STATE_KEY_QA=qa.tfstate
TF_STATE_KEY_PROD=prod.tfstate
```

### Step 3 – Run the Pipeline

Stages executed automatically:

| Stage | Description |
|-------|--------------|
| `platform_mg` | Creates Management Groups |
| `platform_connectivity` | Deploys hub VNet, Firewall, and DNS |
| `env_dev` | Deploys Dev spoke + UDR |
| `env_qa` | Deploys QA spoke + ACR + UDR |
| `env_prod` | Manual approval → deploys Prod AKS/ACR/KV/PEs + UDR |

---

## 5. Inspecting the Hub

```
rg-platform-connectivity
 ├─ vnet-hub-weu
 │   ├─ AzureFirewallSubnet  → Azure Firewall
 │   ├─ GatewaySubnet        → VPN/ER Gateway (optional)
 │   └─ AzureBastionSubnet   → Bastion
 └─ Private DNS Zones        → For Key Vault, ACR, etc.
```

Hybrid connectivity can be added later with:
```hcl
resource "azurerm_virtual_network_gateway" "vpngw" { ... }
```

---

## 6. Environment Spokes

Each environment (Dev, QA, Prod) uses the same pattern:
- Spoke VNet and subnets
- Peer to the Hub
- UDR routes to Azure Firewall
- Environment-specific resources (AKS, ACR, Key Vault, etc.)

---

## 7. Validate Deployment

```bash
az network vnet list -g rg-platform-connectivity -o table
az network firewall show -n afw-hub -g rg-platform-connectivity
az aks get-credentials -n aks-prod-main -g rg-prod-app-services
```

Confirm traffic flows through the firewall by checking UDRs.

---

## 8. Extending the Landing Zone

- Add Azure Policies for tagging, logging, and TLS enforcement.  
- Integrate Log Analytics for diagnostics.  
- Add Private DNS links for cross-spoke name resolution.  
- Deploy VPN or ExpressRoute Gateway in `GatewaySubnet`.

---

## Conclusion

You now have a **production-ready Azure Landing Zone** implemented as code:
- Governance through Management Groups  
- Secure networking with Firewall + UDRs  
- Isolated Dev/QA/Prod spokes  
- Automated CI/CD with Azure DevOps  
- Centralized identity with Microsoft Entra ID  

This architecture is scalable, auditable, and compliant — a true foundation for your enterprise workloads.