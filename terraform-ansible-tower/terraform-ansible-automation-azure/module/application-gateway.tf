################################################ Azure Application Gateway For Ansible Automation #########################################################

resource "azurerm_public_ip" "public_ip_gateway_ansible_automation" {
  name                = "vmss-public-ip-ansible-automation"
  resource_group_name = azurerm_resource_group.ansible_automation_rg.name
  location            = azurerm_resource_group.ansible_automation_rg.location
  sku                 = "Standard"   ### You can select between Basic and Standard.
  allocation_method   = "Static"     ### You can select between Static and Dynamic.
}

resource "azurerm_application_gateway" "application_gateway_ansible_automation" {
  name                = "${var.prefix}-application-gateway"
  resource_group_name = azurerm_resource_group.ansible_automation_rg.name
  location            = azurerm_resource_group.ansible_automation_rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
#   capacity = 2
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 3
  }

  gateway_ip_configuration {
    name      = "ansible_automation-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgtw_subnet.id
  }

  frontend_port {
    name = "${var.prefix}-gateway-subnet-feport-ansible-automation"
    port = 80
  }

  frontend_port {
    name = "${var.prefix}-gateway-subnet-feporthttps-ansible-automation"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-gateway-subnet-feip-ansible-automation"
    public_ip_address_id = azurerm_public_ip.public_ip_gateway_ansible_automation.id
  }

  backend_address_pool {
    name = "${var.prefix}-gateway-subnet-beap-ansible-automation"
    ip_addresses = concat(azurerm_network_interface.vnet_interface_ansible_automation.*.private_ip_address)
  }

  backend_http_settings {
    name                  = "${var.prefix}-gateway-subnet-be-htst-ansible-automation"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
    probe_name            = "${var.prefix}-gateway-subnet-be-probe-app1-ansible-automation"
    host_name             = "ansible-automation.singhritesh85.com"
    pick_host_name_from_backend_address = false
  }

  probe {
    name                = "${var.prefix}-gateway-subnet-be-probe-app1-ansible-automation"
    host                = "ansible-automation.singhritesh85.com"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    protocol            = "Https"
    port                = 443
    path                = "/api/v2/ping/"
    pick_host_name_from_backend_http_settings = false
  }

  # HTTPS Listener - Port 80
  http_listener {
    name                           = "${var.prefix}-gateway-subnet-httplstn-ansible-automation"
    frontend_ip_configuration_name = "${var.prefix}-gateway-subnet-feip-ansible-automation"
    frontend_port_name             = "${var.prefix}-gateway-subnet-feport-ansible-automation"
    protocol                       = "Http"
  }

  # HTTP Routing Rule - Port 80
  request_routing_rule {
    name                       = "${var.prefix}-gateway-subnet-rqrt-ansible-automation"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-gateway-subnet-httplstn-ansible-automation"
    backend_address_pool_name  = "${var.prefix}-gateway-subnet-beap-ansible-automation"  ###  It should not be used when redirection of HTTP to HTTPS is configured.
    backend_http_settings_name = "${var.prefix}-gateway-subnet-be-htst-ansible-automation"   ###  It should not be used when redirection of HTTP to HTTPS is configured.
#    redirect_configuration_name = "${var.prefix}-gateway-subnet-rdrcfg-ansible-automation"
  }

  # Redirect Config for HTTP to HTTPS Redirect
#  redirect_configuration {
#    name = "${var.prefix}-gateway-subnet-rdrcfg-ansible-automation"
#    redirect_type = "Permanent"
#    target_listener_name = "${var.prefix}-lstn-https-ansible-automation"    ### "${var.prefix}-gateway-subnet-httplstn"
#    include_path = true
#    include_query_string = true
#  }

  # SSL Certificate Block
  ssl_certificate {
    name = "${var.prefix}-certificate"
    password = var.ssl_certificate_password
    data = filebase64("mykey.pfx")
  }

  # HTTPS Listener - Port 443
  http_listener {
    name                           = "${var.prefix}-lstn-https-ansible-automation"
    frontend_ip_configuration_name = "${var.prefix}-gateway-subnet-feip-ansible-automation"
    frontend_port_name             = "${var.prefix}-gateway-subnet-feporthttps-ansible-automation"
    protocol                       = "Https"
    ssl_certificate_name           = "${var.prefix}-certificate"
  }

  # HTTPS Routing Rule - Port 443
  request_routing_rule {
    name                       = "${var.prefix}-rqrt-https-ansible-automation"
    priority                   = 101
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-lstn-https-ansible-automation"
    backend_address_pool_name  = "${var.prefix}-gateway-subnet-beap-ansible-automation"
    backend_http_settings_name = "${var.prefix}-gateway-subnet-be-htst-ansible-automation"
  }

}
