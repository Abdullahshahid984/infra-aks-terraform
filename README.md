# infra-aks-terraform
# infra-aks-terraform

Terraform skeleton for AKS with:
- Resource group
- AKS cluster
- Node pool
- System-assigned identity

## Usage
```bash
az login
terraform init
terraform plan -var="rg_name=prod-rg" -var="location=East US"
terraform apply -var="rg_name=prod-rg"
