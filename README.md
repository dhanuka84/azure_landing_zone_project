# **Hands-On Guide: Building a Production-Ready Azure Landing Zone (Zero Trust Enhanced)**

In today’s cloud-native world, a well-architected landing zone is the bedrock of a secure, scalable, and well-governed Azure environment.

In this guide, we’ll use a real, working repository — azure\_landing\_zone\_project —

to deploy a production-ready landing zone built with Terraform, automated through Azure DevOps, and secured with a Zero Trust identity and network model.

## **1\. The Architecture: What We’re Building**

This architecture extends the standard Hub-and-Spoke model with modern security principles.

### **Key Zero Trust Enhancements**

* **Credential-less Identity (OIDC & UAMI):**  
  * **CI/CD Pipeline:** Uses **Workload Identity Federation (OIDC)**. Azure DevOps pipelines authenticate to Azure using federated tokens, completely eliminating the need for static Service Principal secrets.  
  * **Application Workloads:** Uses **User-Assigned Managed Identities (UAMI)**. Applications inside AKS (e.g., uami-prod-api-workload) are granted a managed identity, which is then given RBAC roles (like "Key Vault Secrets User") to access other Azure services.  
* **Defense-in-Depth Networking:**  
  * **Policy-Driven Governance:** A "Deny Public IP Creation" policy is applied at the Management Group level, enforcing a core security principle.  
  * **Secure Ingress:** Public traffic is forced through an **Application Gateway (WAF\_v2)**, which provides Web Application Firewall (WAF) protection against OWASP Top 10 attacks.  
  * **Secure API Exposure:** The App Gateway routes traffic to an **internal-only API Management (APIM)** instance, which securely exposes and manages APIs from the private AKS cluster.  
  * **Network Security Groups (NSGs):**  
    * AzureBastionSubnet has its own mandatory, hardened NSG.  
    * All spoke subnets (snet-aks-nodes, snet-private-endpoints) get a default "deny-all-by-default, allow-vnet" NSG.  
    * snet-app-gateway and snet-apim receive specific, required NSGs for their services.  
  * **DDoS Protection:** A central **DDoS Protection Plan** is created in the hub and associated with both the hub and all spoke VNets.  
  * **Automated DNS:** Spoke VNets automatically link to the central Private DNS Zones, ensuring Private Endpoints resolve correctly across the environment.

### **Core Architecture**

* **Governance:** Management Groups (Platform, Non-Production, Production).  
* **Networking (Hub-and-Spoke):**  
  * **Hub VNet:** Hosts Azure Firewall, Bastion, DDoS Plan, and Private DNS Zones.  
  * **Spoke VNets:** For Dev, QA, and Prod. All traffic is routed through the Hub Firewall via UDRs.  
* **Subscriptions:** Connectivity, Dev, QA, Prod.

---

## **2\. Modern Identity: OIDC and UAMI**

We replace legacy Service Principals (SPNs) with modern, credential-less identities.

* **Workload Identity Federation (OIDC):** For CI/CD automation. We create a federated identity in Entra ID that trusts tokens from our Azure DevOps pipeline, removing all secrets from DevOps.  
* **User-Assigned Managed Identity (UAMI):** For application workloads. We create a uami-prod-api-workload identity and assign it to our AKS pods. This identity is then granted RBAC roles.

RBAC assignments via Terraform (New Model):

We now assign roles to the Managed Identity's Principal ID, not a variable holding a secret-based SPN.

Terraform

\# Create the Managed Identity for the application

resource "azurerm\_user\_assigned\_identity" "api" {

  name                \= "uami-prod-api-workload"

  location            \= var.location

  resource\_group\_name \= var.resource\_group\_name

}

\# Assign the UAMI's identity to the Key Vault

module "rbac" {

  assignments \= \[

    {

      scope\_id           \= module.kv.id

      role\_definition    \= "Key Vault Secrets User"

      principal\_objectId \= azurerm\_user\_assigned\_identity.api.principal\_id

    }

  \]

}

This is a more secure, declarative, and manageable approach to identity.

---

## **3\. Project Structure**

infra/

├─ modules/

│  ├─ networking-hub/         \# Hub VNet, Subnets, DNS Zones

│  ├─ azure-firewall/         \# Azure Firewall

│  ├─ udr/                    \# User Defined Routes

│  ├─ networking-spoke/       \# Spoke VNet, Subnets, Peering, DNS Link, Default NSG

│  ├─ aks/                    \# Kubernetes Service

│  ├─ acr/                    \# Container Registry

│  ├─ keyvault/               \# Key Vault

│  ├─ private-endpoint/       \# Private Endpoints

│  ├─ rbac/                   \# Role Assignments

│  ├─ nsg-bastion/      \# NEW: Mandatory NSG for Bastion

│  ├─ nsg-apim/         \# NEW: NSG for APIM

│  ├─ nsg-app-gateway/  \# NEW: NSG for App Gateway

│  ├─ apim/             \# NEW: APIM module

│  └─ app-gateway/      \# NEW: App Gateway module

│

├─ platform/

│  ├─ mg/               \# Manages MGs and "Deny Public IP" policy

│  └─ connectivity/     \# Manages Hub, Firewall, Bastion NSG, DDoS

│

├─ envs/

│  ├─ dev/ qa/         \# Non-Prod environments

│  └─ prod/             \# Prod env deploys AppGW, APIM, AKS, UAMI, etc.

│

└─ pipelines/

   └─ azure-pipelines.yml \# Updated for OIDC

---

## **4\. Step-by-Step Deployment**

### **Step 1 – Set Up Terraform Remote State**

Bash

az group create \-n rg-tfstate \-l westeurope

az storage account create \-n saterraformstate123 \-g rg-tfstate \--sku Standard\_LRS \--encryption-services blob

az storage container create \-n tfstate \--account-name saterraformstate123

### **Step 2 – Configure Azure DevOps (OIDC)**

**1\. Create Service Connections (Workload Identity Federation)**

* In Azure DevOps, go to Project Settings \> Service Connections.  
* Create a new "Azure Resource Manager" service connection.  
* Select **Workload Identity Federation (automatic)**.  
* Create three connections, one for each identity:  
  * azrm-oidc-platform: Scoped to the Connectivity subscription.  
  * azrm-oidc-nonprod: Scoped to the Non-Production subscription(s).  
  * azrm-oidc-prod: Scoped to the Production subscription.  
* *Note: You must grant these identities the necessary RBAC roles in Azure (e.g., Contributor, AcrPush) outside of Terraform.*

**2\. Variable Group vg-terraform**

TF\_STATE\_RG=rg-tfstate

TF\_STATE\_SA=saterraformstate123

TF\_STATE\_CONTAINER=tfstate

TF\_STATE\_KEY\_PLATFORM\_MG=platform\_mg.tfstate

TF\_STATE\_KEY\_CONNECTIVITY=connectivity.tfstate

TF\_STATE\_KEY\_DEV=dev.tfstate

TF\_STATE\_KEY\_QA=qa.tfstate

TF\_STATE\_KEY\_PROD=prod.tfstate

### **Step 3 – Run the Pipeline**

The pipeline (azure-pipelines.yml) is already configured to use the OIDC service connection names (SERVICE\_CONNECTION\_PLATFORM, etc.).

Simply run the pipeline. It will authenticate without secrets and execute the stages:

| Stage | Description |
| :---- | :---- |
| platform\_mg | Creates MGs & "Deny Public IP" policy |
| platform\_connectivity | Deploys Hub VNet, Firewall, Bastion NSG, DDoS, DNS Zones |
| env\_dev | Deploys Dev spoke \+ UDR \+ NSGs |
| env\_qa | Deploys QA spoke \+ ACR \+ UDR \+ NSGs |
| env\_prod | Manual approval → Deploys Prod AppGW/APIM/AKS/ACR/KV/PEs/UAMI \+ UDRs \+ NSGs |

---

## **5\. Inspecting the Hub**

rg-platform-connectivity

 ├─ vnet-hub-weu

 │  ├─ AzureFirewallSubnet  → Azure Firewall

 │  ├─ GatewaySubnet        → VPN/ER Gateway (optional)

 │  └─ AzureBastionSubnet   → Bastion (with Mandatory NSG)

 ├─ Private DNS Zones

 └─ DDoS Protection Plan

## **6\. Environment Spokes**

Each environment (Dev, QA, Prod) uses the same pattern:

* Spoke VNet and subnets.  
* Peer to the Hub.  
* UDR routes all traffic to the Azure Firewall.  
* Associated with the central **DDoS Protection Plan**.  
* **Layered NSGs** (default on subnets, specific on AppGW/APIM).  
* Prod: Hosts **Application Gateway (WAF)** and **internal APIM** for secure API exposure.  
* Environment-specific resources (AKS, ACR, Key Vault) secured with **Private Endpoints**.

## **7\. Validate Deployment**

Bash

az network vnet list \-g rg-platform-connectivity \-o table

az network firewall show \-n afw-hub \-g rg-platform-connectivity

Confirm traffic flows through the firewall by checking UDRs.

---

## **Conclusion**

You now have a **production-ready, Zero Trust-aligned Azure Landing Zone** implemented as code:

* **Governance** through Management Groups and enforceable policies.  
* **Secure Networking** with Firewall, WAF, DDoS, and layered NSGs.  
* **Credential-less Identity** using OIDC for CI/CD and UAMI for workloads.  
* **Isolated Dev/QA/Prod** spokes with secure API exposure.  
* **Automated CI/CD** with Azure DevOps.

This architecture is scalable, auditable, and compliant — a true foundation for your enterprise workloads.

---

## **Local Validation (Dry Run)**

You can validate the syntax of the project locally without logging into Azure.

Navigate to an environment directory:  
Bash  
cd azure\_landing\_zone\_project/infra/envs/prod

1. 

In providers.tf, **temporarily comment out** the backend "azurerm" {} block.  
Terraform  
/\*

backend "azurerm" {}

\*/

2. Run terraform init. This will initialize the local backend and download providers.

Run terraform validate. This checks all syntax and module references.  
Bash  
Operations before validate

$ cd azure\\\_landing\\\_zone\\\_project/infra/envs/prod

$ rm \\-f .terraform.lock.hcl

$ rm \\-rf .terraform

$ terraform init

$ terraform validate

3. **Important:** Undo your changes to providers.tf before committing.
