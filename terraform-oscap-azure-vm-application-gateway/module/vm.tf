############################################## Creation for NSG for Loki Server #######################################################

resource "azurerm_network_security_group" "azure_nsg_httpd" {
#  count               = var.vm_count_rabbitmq
  name                = "httpd-nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "httpd_ssh_azure"
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
    name                       = "azure_nsg_httpd"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]  #Default port for Loki is 3100 but here I am using it through the Application Gateways.
    source_address_prefixes    = ["10.224.0.0/12"]
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.env
  }
}

########################################## Create Public IP and Network Interface for Loki #############################################

resource "azurerm_public_ip" "public_ip_httpd" {
  name                = "httpd-ip"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  allocation_method   = var.static_dynamic[0]

  sku = "Standard"   ### Basic, For Availability Zone to be Enabled the SKU of Public IP must be Standard
  zones = var.availability_zone

  tags = {
    environment = var.env
  }
}

resource "azurerm_network_interface" "vnet_interface_httpd" {
  name                = "httpd-nic"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  ip_configuration {
    name                          = "httpd-ip-configuration"
    subnet_id                     = azurerm_subnet.aks_subnet.id
    private_ip_address_allocation = var.static_dynamic[1]
    public_ip_address_id = azurerm_public_ip.public_ip_httpd.id
  }

  tags = {
    environment = var.env
  }
}

############################################ Attach NSG to Network Interface for Loki #####################################################

resource "azurerm_network_interface_security_group_association" "nsg_nic_httpd" {
#  count                     = 3             ###var.vm_count_rabbitmq
  network_interface_id      = azurerm_network_interface.vnet_interface_httpd.id
  network_security_group_id = azurerm_network_security_group.azure_nsg_httpd.id

}

######################################################## Create Azure VM for Loki ##########################################################

resource "azurerm_linux_virtual_machine" "azure_vm_httpd" {
  name                  = "httpd-vm"
  location              = azurerm_resource_group.aks_rg.location
  resource_group_name   = azurerm_resource_group.aks_rg.name
  network_interface_ids = [azurerm_network_interface.vnet_interface_httpd.id]
  size                  = var.vm_size
  zone                 = var.availability_zone[0]
  computer_name  = "httpd-vm"
  admin_username = var.admin_username
  admin_password = var.admin_password
  custom_data    = filebase64("custom_data_httpd.sh")
  disable_password_authentication = false

  #### Boot Diagnostics is Enable with managed storage account ########
  boot_diagnostics {
    storage_account_uri  = ""
  }

  source_image_reference {
    publisher = "almalinux"      ###"OpenLogic"
    offer     = "almalinux-x86_64"      ###"CentOS"
    sku       = "8-gen2"         ###"7_9-gen2"
    version   = "latest"         ###"latest"
  }
  os_disk {
    name              = "httpd-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb      = var.disk_size_gb
  }

  tags = {
    environment = var.env
  }

  depends_on = [azurerm_managed_disk.disk_httpd]
}

resource "azurerm_managed_disk" "disk_httpd" {
  name                 = "httpd-datadisk"
  location             = azurerm_resource_group.aks_rg.location
  resource_group_name  = azurerm_resource_group.aks_rg.name
  zone                 = var.availability_zone[0]
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.extra_disk_size_gb
}


resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment_httpd" {
  managed_disk_id    = azurerm_managed_disk.disk_httpd.id
  virtual_machine_id = azurerm_linux_virtual_machine.azure_vm_httpd.id
  lun                ="0"
  caching            = "ReadWrite"
}

############################################## Creation for NSG for OSCAP Server #######################################################

resource "azurerm_network_security_group" "azure_nsg_oscap" {
#  count               = var.vm_count_rabbitmq
  name                = "oscap-nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "oscap_ssh_azure"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.env
  }
}

########################################## Create Public IP and Network Interface for OSCAP #############################################

resource "azurerm_public_ip" "public_ip_oscap" {
  name                = "oscap-ip"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  allocation_method   = var.static_dynamic[0]

  sku = "Standard"   ### Basic, For Availability Zone to be Enabled the SKU of Public IP must be Standard
  zones = var.availability_zone

  tags = {
    environment = var.env
  }
}

resource "azurerm_network_interface" "vnet_interface_oscap" {
  name                = "oscap-nic"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  ip_configuration {
    name                          = "oscap-ip-configuration"
    subnet_id                     = azurerm_subnet.aks_subnet.id
    private_ip_address_allocation = var.static_dynamic[1]
    public_ip_address_id = azurerm_public_ip.public_ip_oscap.id
  }

  tags = {
    environment = var.env
  }
}

############################################ Attach NSG to Network Interface for OSCAP #####################################################

resource "azurerm_network_interface_security_group_association" "nsg_nic_oscap" {
#  count                     = 3             ###var.vm_count_rabbitmq
  network_interface_id      = azurerm_network_interface.vnet_interface_oscap.id
  network_security_group_id = azurerm_network_security_group.azure_nsg_oscap.id

}

######################################################## Create Azure VM for OSCAP ##########################################################

resource "azurerm_linux_virtual_machine" "azure_vm_oscap" {
  name                  = "oscap-vm"
  location              = azurerm_resource_group.aks_rg.location
  resource_group_name   = azurerm_resource_group.aks_rg.name
  network_interface_ids = [azurerm_network_interface.vnet_interface_oscap.id]
  size                  = var.vm_size
  zone                 = var.availability_zone[0]
  computer_name  = "oscap-vm"
  admin_username = var.admin_username
  admin_password = var.admin_password
#  custom_data    = filebase64("custom_data_httpd.sh")
  disable_password_authentication = false

  #### Boot Diagnostics is Enable with managed storage account ########
  boot_diagnostics {
    storage_account_uri  = ""
  }

  source_image_reference {
    publisher = "almalinux"      ###"OpenLogic"
    offer     = "almalinux-x86_64"      ###"CentOS"
    sku       = "8-gen2"         ###"7_9-gen2"
    version   = "latest"         ###"latest"
  }
  os_disk {
    name              = "oscap-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb      = var.disk_size_gb
  }

  tags = {
    environment = var.env
  }

  depends_on = [azurerm_managed_disk.disk_oscap]
}

resource "azurerm_managed_disk" "disk_oscap" {
  name                 = "oscap-datadisk"
  location             = azurerm_resource_group.aks_rg.location
  resource_group_name  = azurerm_resource_group.aks_rg.name
  zone                 = var.availability_zone[0]
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.extra_disk_size_gb
}


resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment_oscap" {
  managed_disk_id    = azurerm_managed_disk.disk_oscap.id
  virtual_machine_id = azurerm_linux_virtual_machine.azure_vm_oscap.id
  lun                ="0"
  caching            = "ReadWrite"
}

############################################## Creation for NSG for OSCAP Server2 #######################################################

resource "azurerm_network_security_group" "azure_nsg_oscap2" {
#  count               = var.vm_count_rabbitmq
  name                = "oscap-nsg2"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "oscap_ssh_azure2"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.env
  }
}

########################################## Create Public IP and Network Interface for OSCAP2 #############################################

resource "azurerm_public_ip" "public_ip_oscap2" {
  name                = "oscap-ip2"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  allocation_method   = var.static_dynamic[0]

  sku = "Standard"   ### Basic, For Availability Zone to be Enabled the SKU of Public IP must be Standard
  zones = var.availability_zone

  tags = {
    environment = var.env
  }
}

resource "azurerm_network_interface" "vnet_interface_oscap2" {
  name                = "oscap-nic2"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  ip_configuration {
    name                          = "oscap-ip-configuration2"
    subnet_id                     = azurerm_subnet.aks_subnet.id
    private_ip_address_allocation = var.static_dynamic[1]
    public_ip_address_id = azurerm_public_ip.public_ip_oscap2.id
  }

  tags = {
    environment = var.env
  }
}

############################################ Attach NSG to Network Interface for OSCAP2 #####################################################

resource "azurerm_network_interface_security_group_association" "nsg_nic_oscap2" {
#  count                     = 3             ###var.vm_count_rabbitmq
  network_interface_id      = azurerm_network_interface.vnet_interface_oscap2.id
  network_security_group_id = azurerm_network_security_group.azure_nsg_oscap2.id

}

######################################################## Create Azure VM for OSCAP2 ##########################################################

resource "azurerm_linux_virtual_machine" "azure_vm_oscap2" {
  name                  = "oscap-vm2"
  location              = azurerm_resource_group.aks_rg.location
  resource_group_name   = azurerm_resource_group.aks_rg.name
  network_interface_ids = [azurerm_network_interface.vnet_interface_oscap2.id]
  size                  = var.vm_size
  zone                 = var.availability_zone[0]
  computer_name  = "oscap-vm2"
  admin_username = var.admin_username
  admin_password = var.admin_password
#  custom_data    = filebase64("custom_data_httpd.sh")
  disable_password_authentication = false

  #### Boot Diagnostics is Enable with managed storage account ########
  boot_diagnostics {
    storage_account_uri  = ""
  }

  source_image_reference {
    publisher = "Canonical"      ###"OpenLogic"
    offer     = "0001-com-ubuntu-server-jammy"      ###"CentOS"
    sku       = "22_04-lts-gen2"         ###"7_9-gen2"
    version   = "latest"         ###"latest"
  }
  os_disk {
    name              = "oscap-osdisk2"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb      = var.disk_size_gb
  }

  tags = {
    environment = var.env
  }

  depends_on = [azurerm_managed_disk.disk_oscap2]
}

resource "azurerm_managed_disk" "disk_oscap2" {
  name                 = "oscap-datadisk2"
  location             = azurerm_resource_group.aks_rg.location
  resource_group_name  = azurerm_resource_group.aks_rg.name
  zone                 = var.availability_zone[0]
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.extra_disk_size_gb
}


resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment_oscap2" {
  managed_disk_id    = azurerm_managed_disk.disk_oscap2.id
  virtual_machine_id = azurerm_linux_virtual_machine.azure_vm_oscap2.id
  lun                ="0"
  caching            = "ReadWrite"
}

############################################## Creation for NSG for Ansible Controller #######################################################

resource "azurerm_network_security_group" "azure_nsg_ansible" {
#  count               = var.vm_count_rabbitmq
  name                = "ansible-nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "ansible_ssh_azure"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.env
  }
}

########################################## Create Public IP and Network Interface for Ansible #############################################

resource "azurerm_public_ip" "public_ip_ansible" {
  name                = "ansible-ip"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  allocation_method   = var.static_dynamic[0]

  sku = "Standard"   ### Basic, For Availability Zone to be Enabled the SKU of Public IP must be Standard
  zones = var.availability_zone

  tags = {
    environment = var.env
  }
}

resource "azurerm_network_interface" "vnet_interface_ansible" {
  name                = "ansible-nic"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  ip_configuration {
    name                          = "ansible-ip-configuration"
    subnet_id                     = azurerm_subnet.aks_subnet.id
    private_ip_address_allocation = var.static_dynamic[1]
    public_ip_address_id = azurerm_public_ip.public_ip_ansible.id
  }

  tags = {
    environment = var.env
  }
}

############################################ Attach NSG to Network Interface for Ansible Controller #####################################################

resource "azurerm_network_interface_security_group_association" "nsg_nic_ansible" {
#  count                     = 3             ###var.vm_count_rabbitmq
  network_interface_id      = azurerm_network_interface.vnet_interface_ansible.id
  network_security_group_id = azurerm_network_security_group.azure_nsg_ansible.id

}

######################################################## Create Azure VM for Ansible Controller ##########################################################

resource "azurerm_linux_virtual_machine" "azure_vm_ansible" {
  name                  = "ansible-controller"
  location              = azurerm_resource_group.aks_rg.location
  resource_group_name   = azurerm_resource_group.aks_rg.name
  network_interface_ids = [azurerm_network_interface.vnet_interface_ansible.id]
  size                  = var.vm_size
  zone                 = var.availability_zone[0]
  computer_name  = "ansible-controller"
  admin_username = var.admin_username
  admin_password = var.admin_password
  custom_data    = filebase64("custom_data_ansible.sh")
  disable_password_authentication = false

  #### Boot Diagnostics is Enable with managed storage account ########
  boot_diagnostics {
    storage_account_uri  = ""
  }

  source_image_reference {
    publisher = "almalinux"      ###"OpenLogic"
    offer     = "almalinux-x86_64"      ###"CentOS"
    sku       = "8-gen2"         ###"7_9-gen2"
    version   = "latest"         ###"latest"
  }
  os_disk {
    name              = "ansible-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb      = var.disk_size_gb
  }

  tags = {
    environment = var.env
  }

  depends_on = [azurerm_managed_disk.disk_ansible]
}

resource "azurerm_managed_disk" "disk_ansible" {
  name                 = "ansible-datadisk"
  location             = azurerm_resource_group.aks_rg.location
  resource_group_name  = azurerm_resource_group.aks_rg.name
  zone                 = var.availability_zone[0]
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.extra_disk_size_gb
}


resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment_ansible" {
  managed_disk_id    = azurerm_managed_disk.disk_ansible.id
  virtual_machine_id = azurerm_linux_virtual_machine.azure_vm_ansible.id
  lun                ="0"
  caching            = "ReadWrite"
}
