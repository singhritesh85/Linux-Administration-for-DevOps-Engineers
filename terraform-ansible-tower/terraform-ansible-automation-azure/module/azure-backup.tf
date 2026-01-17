###################################################### Azure VM Backup ######################################################

resource "random_id" "id3" {
  byte_length = 4

}

resource "azurerm_recovery_services_vault" "recovery_svc_vault" {
  name                = "${var.prefix}-recovery-vault"
  location            = azurerm_resource_group.ansible_automation_rg.location
  resource_group_name = azurerm_resource_group.ansible_automation_rg.name
  sku                 = "Standard"
  soft_delete_enabled = false      ### If enabled, deleted backup items are not immediately and permanently removed.
  identity {
    type = "SystemAssigned"
  } 
}

resource "azurerm_backup_policy_vm" "azure_vm_backup_policy" {
  name                = "${var.prefix}-recovery-vault-policy"
  resource_group_name = azurerm_resource_group.ansible_automation_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.recovery_svc_vault.name
  policy_type = "V2"  ### V2 shows Enhanced type which leverage Multiple backups per day.

  timezone = "UTC"

  backup {
    frequency = "Hourly"
    time      = "17:30"
    hour_interval = "12"
    hour_duration = "24"
  }

  instant_restore_retention_days = 7
  instant_restore_resource_group {
    prefix = "${var.prefix}-backup"
    suffix = random_id.id3.hex
  }

  retention_daily {
    count = 30
  }
}

resource "azurerm_backup_protected_vm" "devops_agent_vm" {
  count               = var.vm_count
  resource_group_name = azurerm_resource_group.ansible_automation_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.recovery_svc_vault.name
  source_vm_id        = azurerm_linux_virtual_machine.azure_vm_ansible_automation[count.index].id
  backup_policy_id    = azurerm_backup_policy_vm.azure_vm_backup_policy.id
}
