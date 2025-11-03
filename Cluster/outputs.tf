output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_kubeconfig_command" {
  description = "Command to get AKS credentials"
  value       = "az aks get-credentials -g ${azurerm_resource_group.rg.name} -n ${azurerm_kubernetes_cluster.aks.name}"
}

output "aks_cluster_location" {
  description = "The location where the AKS cluster is deployed"
  value       = azurerm_kubernetes_cluster.aks.location
}

output "aks_cluster_node_resource_group" {
  description = "The auto-generated node resource group for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = azurerm_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = azurerm_subnet.private_subnet.id
}

output "network_security_group_id" {
  description = "The ID of the network security group"
  value       = azurerm_network_security_group.nsg.id
}

output "public_ip_address" {
  description = "The public IP address associated with the NAT gateway"
  value       = azurerm_public_ip.public_ip.ip_address
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = azurerm_nat_gateway.nat.id
}
