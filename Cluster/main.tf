resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksdemo"

  default_node_pool {
    name                       = "publicpool"
    node_count                 = 1
    vm_size                    = var.node_vm_size
    vnet_subnet_id             = azurerm_subnet.public_subnet.id
    type                       = "VirtualMachineScaleSets"
    temporary_name_for_rotation = "tmp1"
  }

  network_profile {
    network_plugin   = "azure"
    network_policy   = "azure"
    outbound_type    = "loadBalancer"
    service_cidr     = "10.200.0.0/16"
    dns_service_ip   = "10.200.0.10"
  }

  private_cluster_enabled = false

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "privatepool" {
  name                  = "privatepool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.node_vm_size
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.private_subnet.id
}
