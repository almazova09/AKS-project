variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "westus2"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "aks-resources"
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
  default     = "aks-network"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_prefix" {
  description = "Address prefix for the public subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_prefix" {
  description = "Address prefix for the private subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "my-aks-cluster"
}

variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}
