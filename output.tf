output "resource_group_name" {
  value = azurerm_resource_group.anup-test-rg.name
}

output "private_key_pem" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}

output "aks_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.default.name
}