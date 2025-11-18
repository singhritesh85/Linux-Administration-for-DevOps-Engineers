#############################################################################################################################
# Provision AKS Cluster
#############################################################################################################################

# Create Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Create VNet for AKS
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  address_space       = ["10.224.0.0/12"]
}

# Create Subnet for VNet of AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = "default"         ###"${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.Storage"]
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.224.0.0/16"]
  depends_on = [azurerm_virtual_network.aks_vnet]
}

# Create Subnet for VNet of Application Gateway
resource "azurerm_subnet" "appgtw_subnet" {
  name                 = "subnet-1"         ###"${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
#  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.Storage"]
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.225.0.0/16"]
  depends_on = [azurerm_virtual_network.aks_vnet]
}

# Create Subnet for PostgreSQL Flexible servers
resource "azurerm_subnet" "postgresql_flexible_server_subnet" {
  name                 = "${var.prefix}-postgresql-flexible-server-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.227.0.0/16"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "postgres-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}


