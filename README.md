# infra-aks-terraform

Production-ready **Terraform** for provisioning **Azure Kubernetes Service (AKS)** with enterprise-grade components:

* Resource Group, VNet, Subnet
* AKS cluster (system + user node pools)
* Managed Identity + Role Assignments
* Azure Policy for compliance & governance
* Key Vault integration for secrets
* CI/CD with GitHub Actions or Jenkins

---

## Repo Structure

```
infra-aks-terraform/
├── main.tf               # Providers + Backend
├── network.tf            # VNet & Subnets
├── aks.tf                # AKS Cluster + Node Pools
├── identity.tf           # Managed Identity + Role Assignments
├── policies.tf           # Azure Policies for compliance
├── keyvault.tf           # Key Vault + Secret integration
├── variables.tf          # Variables
├── outputs.tf            # Outputs
└── README.md             # Documentation
```

---

## Prerequisites

* [Terraform >= 1.4](https://developer.hashicorp.com/terraform/downloads)
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* A remote backend (Azure Storage Account for state)

Login first:

```bash
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
```

---

## Usage

Initialize:

```bash
terraform init
```

Plan:

```bash
terraform plan -var="rg_name=prod-rg" -var="location=East US"
```

Apply:

```bash
terraform apply -auto-approve
```

Get Kubeconfig:

```bash
az aks get-credentials --resource-group prod-rg --name abdullah-aks
```

---

## Managed Identity & Role Assignments

We enable **system-assigned managed identity** for AKS and assign roles like **AcrPull**, **Key Vault Reader**, etc.

Example:

```hcl
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
```

This ensures the AKS cluster can securely pull images from ACR and fetch secrets from Key Vault.

---

##  Azure Policies for Compliance

We enforce security & compliance using **Azure Policy Assignments**:

* Allowed Kubernetes versions
* No privileged containers
* Only HTTPS ingress
* Restrict public IP usage

Example:

```hcl
resource "azurerm_policy_assignment" "aks_secure_baseline" {
  name                 = "aks-secure-baseline"
  scope                = azurerm_kubernetes_cluster.aks.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/abcd1234-xxxx-yyyy-zzzz-987654321"
  identity {
    type = "SystemAssigned"
  }
}
```

---

##  Key Vault Integration

We deploy an **Azure Key Vault** and allow AKS workloads to use it securely via Managed Identity.

```hcl
resource "azurerm_key_vault" "kv" {
  name                = "${var.prefix}-kv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  secret_permissions = ["Get", "List"]
}
```

Secrets can be injected into pods using the **Azure Key Vault CSI Driver**.

---

## CI/CD Integration

### Option 1: GitHub Actions

`.github/workflows/terraform.yml`

```yaml
name: Terraform Deploy

on:
  push:
    branches: [ main ]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -out=tfplan

      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
```

### Option 2: Jenkins Pipeline

```groovy
pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Terraform Init') {
      steps { sh 'terraform init' }
    }
    stage('Terraform Plan') {
      steps { sh 'terraform plan -out=tfplan' }
    }
    stage('Terraform Apply') {
      steps { sh 'terraform apply -auto-approve tfplan' }
    }
  }
}
```

---

## Outputs

```bash
terraform output aks_name
terraform output aks_rg
terraform output kube_config
```

---

##  Next Enhancements

* Enable Azure Monitor / Log Analytics
* Add Istio or Nginx Ingress Controller
* Add Backup & DR (Velero / Azure Backup for AKS)
* Integrate with ArgoCD or Flux for GitOps

---

 With this setup, you can show clients a **secure, production-ready AKS Terraform stack** with **enterprise DevOps best practices**.

---
