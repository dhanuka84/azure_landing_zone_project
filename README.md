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