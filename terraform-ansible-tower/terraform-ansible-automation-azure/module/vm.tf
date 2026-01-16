############################################## Creation for NSG for Ansible Automation #######################################################

resource "azurerm_network_security_group" "azure_nsg_ansible_automation" {
  count               = var.vm_count
  name                = "ansible-automation-nsg-${count.index + 1}"
  location            = azurerm_resource_group.ansible_automation_rg.location
  resource_group_name = azurerm_resource_group.ansible_automation_rg.name

  security_rule {
    name                       = "ansible-automation-ssh-azure"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "azure-nsg-ansible-automation"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "27199"
    source_address_prefixes    = ["10.10.0.0/16"]
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.env
  }
}

########################################## Create Public IP and Network Interface for Ansible Automation #############################################

resource "azurerm_public_ip" "public_ip_ansible_automation" {
  count               = var.vm_count
  name                = "ansible-automation-ip-${count.index + 1}"
  resource_group_name = azurerm_resource_group.ansible_automation_rg.name
  location            = azurerm_resource_group.ansible_automation_rg.location
  allocation_method   = var.static_dynamic[0]

  sku = "Standard"   ### Basic, For Availability Zone to be Enabled the SKU of Public IP must be Standard
  zones = var.availability_zone

  tags = {
    environment = var.env
  }
}

resource "azurerm_network_interface" "vnet_interface_ansible_automation" {
  count               = var.vm_count
  name                = "ansible-automation-nic-${count.index + 1}"
  location            = azurerm_resource_group.ansible_automation_rg.location
  resource_group_name = azurerm_resource_group.ansible_automation_rg.name

  ip_configuration {
    name                          = "ansible_automation-ip-configuration-${count.index + 1}"
    subnet_id                     = azurerm_subnet.aks_subnet.id
    private_ip_address_allocation = var.static_dynamic[1]
    public_ip_address_id = azurerm_public_ip.public_ip_ansible_automation[count.index].id
  }

  tags = {
    environment = var.env
  }
}

############################################ Attach NSG to Network Interface for Ansible Automation ####################################################

resource "azurerm_network_interface_security_group_association" "nsg_nic_ansible_automation" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.vnet_interface_ansible_automation[count.index].id
  network_security_group_id = azurerm_network_security_group.azure_nsg_ansible_automation[count.index].id

}

####################################################### Create Azure VM for Ansible Automation #########################################################

resource "azurerm_linux_virtual_machine" "azure_vm_ansible_automation" {
  count                 = var.vm_count
  name                  = "ansible-automation-vm-${count.index + 1}"
  location              = azurerm_resource_group.ansible_automation_rg.location
  resource_group_name   = azurerm_resource_group.ansible_automation_rg.name
  network_interface_ids = [azurerm_network_interface.vnet_interface_ansible_automation[count.index].id]
  size                  = var.vm_size
  zone                 = var.availability_zone[0]
  computer_name  = "ansible-automation-vm-${count.index + 1}"
  admin_username = var.admin_username
  admin_password = var.admin_password
  custom_data    = filebase64("custom_data_ansible_core.sh")
  disable_password_authentication = false

  #### Boot Diagnostics is Enable with managed storage account ########
  boot_diagnostics {
    storage_account_uri  = ""
  }

  source_image_reference {
    publisher = "RedHat"   ###"almalinux"      ###"OpenLogic"
    offer     = "RHEL"     ###"almalinux-x86_64"      ###"CentOS"
    sku       = "9-LVM"    ###"8-gen2"         ###"7_9-gen2"
    version   = "latest"   ###"latest"         ###"latest"
  }
  os_disk {
    name              = "ansible_automation-osdisk-${count.index + 1}"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb      = var.disk_size_gb
  }

  tags = {
    environment = var.env
  }

  depends_on = [azurerm_managed_disk.disk_ansible_automation]
}

resource "azurerm_managed_disk" "disk_ansible_automation" {
  count                = var.vm_count
  name                 = "ansible_automation-datadisk-${count.index + 1}"
  location             = azurerm_resource_group.ansible_automation_rg.location
  resource_group_name  = azurerm_resource_group.ansible_automation_rg.name
  zone                 = var.availability_zone[0]
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.extra_disk_size_gb
}


resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment_ansible_automation" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.disk_ansible_automation[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.azure_vm_ansible_automation[count.index].id
  lun                = "0"
  caching            = "ReadWrite"
}
