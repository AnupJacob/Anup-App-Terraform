variable "resource_group_location" {
  type        = string
  default     = "northeurope"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "node_count_kub" {
  type        = string
  default     = "1"
  description = "Node count for kubernetes cluster."
}

variable "vm_size_kub" {
  type        = string
  default     = "Standard_B2s"
  description = "VM size for kubernetes nodes."
}

variable "vm_size_azure" {
  type        = string
  default     = "Standard_F2"
  description = "VM size for azure."
}

variable "azure_user" {
  type        = string
  default     = "azureuser"
  description = "Azure username admin"
}

variable "acr_sku" {
  description = "ACR SKU"
  type        = string
  default     = "Standard"
}