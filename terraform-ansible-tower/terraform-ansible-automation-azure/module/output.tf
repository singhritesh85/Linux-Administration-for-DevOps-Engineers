output "postgresql_flexible_server_name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.azure_postgresql.name
}

output "postgresql_flexible_server_fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.azure_postgresql.fqdn 
}

output "public_ip_address_of_Azure_VMs" {
  description = "The public IP address of the Linux VMs"
  value       = azurerm_public_ip.public_ip_ansible_automation[*].ip_address
}

output "Azure_VMs_Private_IP" {
  description = "The private IP address of the Azure VMs"
  value       = azurerm_network_interface.vnet_interface_ansible_automation[*].private_ip_address
}

output "azure_application_gateway_name" {
  description = "The name of the Azure Application Gateway"
  value       = azurerm_application_gateway.application_gateway_ansible_automation.name
}

output "azure_application_gateway_public_ip_address" {
  description = "The public IP address of the Azure Application Gateway"
  value       = azurerm_public_ip.public_ip_gateway_ansible_automation.ip_address
}
