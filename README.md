# infra-aks-terraform

Production-ready Terraform for AKS including:
- Resource Group
- Virtual Network + Subnet
- AKS cluster (system pool + user pool)
- System-assigned identity
- RBAC enabled

---

## 🚀 Usage
```bash
az login
terraform init
terraform plan -var="rg_name=prod-rg" -var="location=East US"
terraform apply -auto-approve
