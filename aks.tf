resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-dns"
  kubernetes_version  = var.k8s_version
  node_resource_group = "${var.prefix}-nodes-rg"

  default_node_pool {
    name                = "systempool"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
    os_disk_size_gb     = 50
    orchestrator_version = var.k8s_version
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 2
  mode                  = "User"
  vnet_subnet_id        = azurerm_subnet.aks_subnet.id
}
