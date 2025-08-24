# managed_identity_and_roles.tf

# Give AKS cluster a system-assigned identity (already present in aks.tf via identity { type = "SystemAssigned" })
# Create role assignments for that identity (example: Reader on resource group and Key Vault Secrets User on Key Vault)

resource "azurerm_role_assignment" "aks_rg_reader" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader" # or use role_definition_id
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

# assign Key Vault Secrets User (built-in) to AKS identity once Key Vault exists
resource "azurerm_role_assignment" "aks_keyvault_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  # Ensure KV is created before role assignment
  depends_on = [azurerm_key_vault.kv]
}
