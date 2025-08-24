# policy.tf

# Simple policy definition that enforces allowed locations (example JSON)
resource "azurerm_policy_definition" "allowed_locations" {
  name         = "${var.prefix}-allowed-locations"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed locations for resources - custom"

  policy_rule = <<POLICY
{
  "if": {
    "not": {
      "field": "location",
      "in": [
        "eastus",
        "eastus2",
        "centralus"
      ]
    }
  },
  "then": {
    "effect": "deny"
  }
}
POLICY

  description = "Allow only specified Azure locations."
}

resource "azurerm_policy_assignment" "rg_allowed_locations" {
  name                 = "${var.prefix}-assign-allowed-loc"
  scope                = azurerm_resource_group.rg.id
  policy_definition_id = azurerm_policy_definition.allowed_locations.id
  display_name         = "Restrict locations in RG"
}
