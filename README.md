---

# **Hands-On Guide: Building a Production-Ready Azure Landing Zone with Terraform and Entra ID**

In today’s cloud-native world, a well-architected landing zone is the bedrock of a secure, scalable, and well-governed Azure environment.  
In this guide, we’ll use a real, working repository — azure\_landing\_zone\_project —  
to deploy a production-ready landing zone built with Terraform, automated through Azure DevOps, and governed by Microsoft Entra ID.

---

## **1\. The Mental Model: What We’re Building**

### **Governance**

* **Management Groups**: Platform, Non-Production, and Production — enforcing policies and compliance.

### **Networking**

* **Hub-and-Spoke Architecture**  
  * **Hub VNet (vnet-hub-weu)**  
    * AzureFirewallSubnet: hosts Azure Firewall (zone redundant)  
    * GatewaySubnet: reserved for VPN/ExpressRoute Gateway  
    * AzureBastionSubnet: secure RDP/SSH via Bastion  
    * **Private DNS Zones**: for private endpoints (Key Vault, ACR)  
  * **Spoke VNets** for Dev, QA, and Prod environments.

### **Subscriptions**

* Connectivity → Hub & shared resources  
* Dev, QA, Prod → Isolated workloads and billing separation

---

## **2\. Identity and Security with Microsoft Entra ID**

| Identity | Purpose | Access Scope |
| :---- | :---- | :---- |
| app-cicd-pipeline | CI/CD automation | Contributor (Dev/QA), AKS Admin (Prod) |
| app-backend-api | Workload identity | Key Vault & ACR |
| app-monitor | Monitoring | Reader |

RBAC assignments via Terraform:

Terraform

module "rbac" {  
  assignments \= \[  
    {  
      scope\_id           \= module.acr.id  
      role\_definition    \= "AcrPush"  
      principal\_objectId \= var.spn\_app\_cicd\_prod  
    },  
    {  
      scope\_id           \= module.kv.id  
      role\_definition    \= "Key Vault Secrets User"  
      principal\_objectId \= var.spn\_key\_vault\_api\_prod  
    }  
  \]  
}

### **What each identity type means**

| Type | Lifecycle & characteristics | Key properties |
| :---- | :---- | :---- |
| **System-Assigned Managed Identity** | Created and tied to a specific Azure resource (e.g., an AKS cluster). When the resource is deleted, the identity is also deleted. [Microsoft Learn+2Microsoft Learn+2](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview?utm_source=chatgpt.com) | • One identity per resource. • Cannot be shared across resources. • Easier to enable (just toggle on). |
| **User-Assigned Managed Identity** | Created independently as its own Azure resource. It can be assigned to one or more Azure resources. Lifespan is independent of the resources. [Microsoft Learn+1](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview?utm_source=chatgpt.com) | • Can be used by multiple resources. • Pre-provisioning possible (identity exists ahead of resource creation). • More granular sharing & reuse. |

---

### **When to choose which**

From Microsoft’s best-practice guidance and community experience: [Microsoft Learn+2John Folberth+2](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/managed-identity-best-practice-recommendations?utm_source=chatgpt.com)

### **Choose User-Assigned Managed Identity (UAMI) when:**

* You have **multiple resources** (e.g., clusters, node-pools, VMs) that need **the same** access to downstream resources (KeyVault, Blob, etc). UAMI allows sharing one identity across many. [Microsoft Learn+1](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/managed-identity-best-practice-recommendations?utm_source=chatgpt.com)

* You want to **pre-assign role-based access control (RBAC)** to an identity *before* creating the resource, to avoid “chicken and egg” issues when provisioning infrastructure. [Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/managed-identity-best-practice-recommendations?utm_source=chatgpt.com)

* You want identity management decoupled from the resource life-cycle (so deleting a cluster doesn’t delete the identity).

* You want to reduce the number of identities/objects in Microsoft Entra ID (avoiding too many SAMIs hitting quotas) or want clearer identity management at enterprise scale. [Reddit](https://www.reddit.com/r/AZURE/comments/1g44efo/monitoring_agent_system_assigned_identity_vs_user/?utm_source=chatgpt.com)

### **Choose System-Assigned Managed Identity (SAMI) when:**

* The identity is very tightly scoped to a single resource, and you don’t need reuse across other resources.

* You want lifecycle alignment: delete the resource → identity is removed too (reducing “orphan” identities).

* Simpler scenario where identity sharing, reuse and pre-provisioning are not required.

---

### **Best for AKS clusters**

For an AKS cluster, here are considerations:

* According to the official AKS docs: You *can* use either SAMI or UAMI for AKS. But when you choose UAMI, it has to exist before you create the cluster. [Microsoft Learn](https://learn.microsoft.com/en-us/azure/aks/use-managed-identity?utm_source=chatgpt.com)

* If you have a simple AKS deployment with isolated cluster and minimal downstream dependencies, SAMI may suffice.

* But in most **enterprise/production** scenarios (especially like your “landing-zone” style infrastructure) where you have: multiple node pools, multiple clusters, shared ACR/KeyVault/monitoring roles, desire for consistent identity management across subscriptions/environments — a **User-Assigned Managed Identity** becomes a stronger choice.

---

## **3\. Project Structure**

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

---

## **4\. Step-by-Step Deployment**

### **Step 1 – Set Up Terraform Remote State**

Bash

az group create \-n rg-tfstate \-l westeurope  
az storage account create \-n saterraformstate123 \-g rg-tfstate   \--sku Standard\_LRS \--encryption-services blob  
az storage container create \-n tfstate \--account-name saterraformstate123

### **Step 2 – Configure Azure DevOps**

**Service Connections**

* azrm-platform: Hub subscription  
* azrm-nonprod: Dev \+ QA  
* azrm-prod: Production

**Variable Group vg-terraform**

TF\_STATE\_RG=rg-tfstate  
TF\_STATE\_SA=saterraformstate123  
TF\_STATE\_CONTAINER=tfstate  
TF\_STATE\_KEY\_PLATFORM\_MG=platform\_mg.tfstate  
TF\_STATE\_KEY\_CONNECTIVITY=connectivity.tfstate  
TF\_STATE\_KEY\_DEV=dev.tfstate  
TF\_STATE\_KEY\_QA=qa.tfstate  
TF\_STATE\_KEY\_PROD=prod.tfstate

### **Step 3 – Run the Pipeline**

Stages executed automatically:

| Stage | Description |
| :---- | :---- |
| platform\_mg | Creates Management Groups |
| platform\_connectivity | Deploys hub VNet, Firewall, and DNS |
| env\_dev | Deploys Dev spoke \+ UDR |
| env\_qa | Deploys QA spoke \+ ACR \+ UDR |
| env\_prod | Manual approval → deploys Prod AKS/ACR/KV/PEs \+ UDR |

---

## **5\. Inspecting the Hub**

rg-platform-connectivity  
 ├─ vnet-hub-weu  
 │   ├─ AzureFirewallSubnet  → Azure Firewall  
 │   ├─ GatewaySubnet        → VPN/ER Gateway (optional)  
 │   └─ AzureBastionSubnet   → Bastion  
 └─ Private DNS Zones        → For Key Vault, ACR, etc.

Hybrid connectivity can be added later with:

Terraform

resource "azurerm\_virtual\_network\_gateway" "vpngw" { ... }

---

## **6\. Environment Spokes**

Each environment (Dev, QA, Prod) uses the same pattern:

* Spoke VNet and subnets  
* Peer to the Hub  
* UDR routes to Azure Firewall  
* Environment-specific resources (AKS, ACR, Key Vault, etc.)

---

## **7\. Validate Deployment**

Bash

az network vnet list \-g rg-platform-connectivity \-o table  
az network firewall show \-n afw-hub \-g rg-platform-connectivity  
az aks get-credentials \-n aks-prod-main \-g rg-prod-app-services

Confirm traffic flows through the firewall by checking UDRs.

---

## **8\. Extending the Landing Zone**

* Add Azure Policies for tagging, logging, and TLS enforcement.  
* Integrate Log Analytics for diagnostics.  
* Add Private DNS links for cross-spoke name resolution.  
* Deploy VPN or ExpressRoute Gateway in GatewaySubnet.

---

## **Conclusion**

You now have a **production-ready Azure Landing Zone** implemented as code:

* Governance through Management Groups  
* Secure networking with Firewall \+ UDRs  
* Isolated Dev/QA/Prod spokes  
* Automated CI/CD with Azure DevOps  
* Centralized identity with Microsoft Entra ID

This architecture is scalable, auditable, and compliant — a true foundation for your enterprise workloads.

## Operations before validate
$ cd azure_landing_zone_project/infra/envs/prod
$ rm -f .terraform.lock.hcl
$ rm -rf .terraform
$ terraform init
$ terraform validate