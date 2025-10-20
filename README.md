# Azure DevOps + Terraform Landing Zone

This repository provisions a sample hub-and-spoke Azure landing zone with Dev/QA/Prod spokes, AKS/ACR/Key Vault in Prod, and Private Endpoints with Private DNS in the Hub. It ships with an Azure DevOps multi-stage pipeline (`infra/pipelines/azure-pipelines.yml`).

## Structure
See `infra/` for platform (mg/connectivity), envs (dev/qa/prod), and reusable modules.

## Quick Start
1. Create remote state (RG/SA/container) in the Connectivity subscription.
2. In Azure DevOps, create service connections: `azrm-platform`, `azrm-nonprod`, `azrm-prod` (OIDC recommended).
3. Create variable group `vg-terraform` with TF_STATE_* keys.
4. Push this repo and run the pipeline. Approve the PROD stage when prompted.
