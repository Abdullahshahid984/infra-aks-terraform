variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "abdullah"
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "East US"
}

variable "rg_name" {
  description = "Resource Group name"
  type        = string
  default     = "aks-rg"
}

variable "node_count" {
  description = "Number of system pool nodes"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.3"
}

variable "tags" {
  type = map(string)
  default = {
    owner       = "abdullah"
    environment = "dev"
  }
}
