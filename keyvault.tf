# keyvault.tf

resource "azurerm_key_vault" "kv" {
  name                        = "${var.prefix}-kv"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Access policy to let the AKS cluster's system-assigned identity read secrets
resource "azurerm_key_vault_access_policy" "aks_kv_access" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  secret_permissions = [
    "get",
    "list"
  ]
}

# Example secret (do not store production secrets in TF in real life — prefer separate secret pipeline)
resource "azurerm_key_vault_secret" "example" {
  name         = "example-secret"
  value        = "replace-with-secret-or-use-pipeline"
  key_vault_id = azurerm_key_vault.kv.id
}
