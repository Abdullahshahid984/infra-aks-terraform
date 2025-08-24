# Key Vault + AKS integration notes

- The AKS system-assigned identity is granted `Key Vault Secrets User` role and an access policy with `get/list` secret permissions.
- To consume secrets in workloads:
  - Option A: Use CSI driver for Key Vault (recommended) — deploy Azure Key Vault Provider for Secrets Store CSI Driver; pods will mount secrets as files or projected volumes.
  - Option B: Use Vault Agent or external secret operators (external-secrets, SealedSecrets etc).
- Example: install `secrets-store-csi-driver` + `azure-keyvault-provider` and create a `SecretProviderClass` referencing `azurerm_key_vault.kv` and secret names.
