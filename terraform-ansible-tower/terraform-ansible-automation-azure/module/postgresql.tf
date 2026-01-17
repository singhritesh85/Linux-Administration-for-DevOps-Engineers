############################################### Azure Key Vault for PostgreSQL Flexible Servers #######################################

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault_postgresql" {
  name                        = "${var.prefix}2"
  location                    = azurerm_resource_group.ansible_automation_rg.location
  resource_group_name         = azurerm_resource_group.ansible_automation_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7

  access_policy {
    tenant_id               = data.azurerm_client_config.current.tenant_id
    object_id               = data.azurerm_client_config.current.object_id
    key_permissions         = ["Get", "List", "Delete", "Purge"]
    secret_permissions      = ["Get", "List", "Set", "Delete", "Purge"]
  }
}

resource "azurerm_key_vault_secret" "psql_username" {
  name         = "${var.prefix}-psql-server-username"
  value        = var.psql_server_admin_username
  key_vault_id = azurerm_key_vault.key_vault_postgresql.id
}

resource "random_password" "psql_password" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "azurerm_key_vault_secret" "psql_password" {
  name         = "psql-server-password"
  value        = random_password.psql_password.result
  key_vault_id = azurerm_key_vault.key_vault_postgresql.id
}

resource "azurerm_role_assignment" "key_vault_role_assignment" {
  scope                = azurerm_key_vault.key_vault_postgresql.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

################################################ Azure PostgreSQL Flexible Servers ###################################################

resource "azurerm_private_dns_zone" "sonarqube_private_postgresql" {
  name                = "sonarqube-postgresql3.private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.ansible_automation_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sonarqube_postgresql_vnet_link" {
  name                  = "sonarqubeprivate.com"
  private_dns_zone_name = azurerm_private_dns_zone.sonarqube_private_postgresql.name
  virtual_network_id    = azurerm_virtual_network.aks_vnet.id
  resource_group_name   = azurerm_resource_group.ansible_automation_rg.name
  depends_on            = [azurerm_subnet.postgresql_flexible_server_subnet]
}

resource "azurerm_postgresql_flexible_server" "azure_postgresql" {
  name                          = "sonarqube-postgresql3"
  resource_group_name           = azurerm_resource_group.ansible_automation_rg.name
  location                      = azurerm_resource_group.ansible_automation_rg.location
  version                       = "14"
  delegated_subnet_id           = azurerm_subnet.postgresql_flexible_server_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.sonarqube_private_postgresql.id
  public_network_access_enabled = false
  administrator_login           = azurerm_key_vault_secret.psql_username.value
  administrator_password        = azurerm_key_vault_secret.psql_password.value
  zone                          = "1"

#  high_availability {
#    mode = "ZoneRedundant"
#    standby_availability_zone = 2
#  } 

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name   = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.sonarqube_postgresql_vnet_link]
}

resource "azurerm_postgresql_flexible_server_database" "postgresql_database" {
  name      = "dexter"
  server_id = azurerm_postgresql_flexible_server.azure_postgresql.id
  charset   = "UTF8"
  collation = "en_US.utf8"
 
  lifecycle {
    ignore_changes = [charset, collation]
  }
}
