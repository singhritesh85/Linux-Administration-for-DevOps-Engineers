################################################### Azure Application Gateway For Loki ############################################################

resource "azurerm_public_ip" "public_ip_gateway_httpd" {
  name                = "vmss-public-ip-httpd"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "Standard"   ### You can select between Basic and Standard.
  allocation_method   = "Static"     ### You can select between Static and Dynamic.
}

resource "azurerm_application_gateway" "application_gateway_httpd" {
  name                = "${var.prefix}-application-gateway-httpd"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location

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
    name      = "httpd-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgtw_subnet.id
  }

  frontend_port {
    name = "${var.prefix}-gateway-subnet-feport-httpd"
    port = 80
  }

  frontend_port {
    name = "${var.prefix}-gateway-subnet-feporthttps-httpd"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-gateway-subnet-feip-httpd"
    public_ip_address_id = azurerm_public_ip.public_ip_gateway_httpd.id
  }

  backend_address_pool {
    name = "${var.prefix}-gateway-subnet-beap-httpd"
    ip_addresses = concat(azurerm_network_interface.vnet_interface_httpd.*.private_ip_address)
  }

  backend_http_settings {
    name                  = "${var.prefix}-gateway-subnet-be-htst-httpd"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "${var.prefix}-gateway-subnet-be-probe-app1-httpd"
  }

  probe {
    name                = "${var.prefix}-gateway-subnet-be-probe-app1-httpd"
    host                = "www.singhritesh85.com"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    protocol            = "Http"
    port                = 80
    path                = "/"
  }

  # HTTPS Listener - Port 80
  http_listener {
    name                           = "${var.prefix}-gateway-subnet-httplstn-httpd"
    frontend_ip_configuration_name = "${var.prefix}-gateway-subnet-feip-httpd"
    frontend_port_name             = "${var.prefix}-gateway-subnet-feport-httpd"
    protocol                       = "Http"
  }

  # HTTP Routing Rule - Port 80
  request_routing_rule {
    name                       = "${var.prefix}-gateway-subnet-rqrt-httpd"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-gateway-subnet-httplstn-httpd"
    backend_address_pool_name  = "${var.prefix}-gateway-subnet-beap-httpd"  ###  It should not be used when redirection of HTTP to HTTPS is configured.
    backend_http_settings_name = "${var.prefix}-gateway-subnet-be-htst-httpd"   ###  It should not be used when redirection of HTTP to HTTPS is configured.
#    redirect_configuration_name = "${var.prefix}-gateway-subnet-rdrcfg-httpd"
  }

  # Redirect Config for HTTP to HTTPS Redirect
#  redirect_configuration {
#    name = "${var.prefix}-gateway-subnet-rdrcfg-httpd"
#    redirect_type = "Permanent"
#    target_listener_name = "${var.prefix}-lstn-https-httpd"    ### "${var.prefix}-gateway-subnet-httplstn"
#    include_path = true
#    include_query_string = true
#  }

  # SSL Certificate Block
  ssl_certificate {
    name = "${var.prefix}-certificate"
    password = "Dexter@123"
    data = filebase64("mykey.pfx")
  }

  # HTTPS Listener - Port 443
  http_listener {
    name                           = "${var.prefix}-lstn-https-httpd"
    frontend_ip_configuration_name = "${var.prefix}-gateway-subnet-feip-httpd"
    frontend_port_name             = "${var.prefix}-gateway-subnet-feporthttps-httpd"
    protocol                       = "Https"
    ssl_certificate_name           = "${var.prefix}-certificate"
  }

  # HTTPS Routing Rule - Port 443
  request_routing_rule {
    name                       = "${var.prefix}-rqrt-https-httpd"
    priority                   = 101
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-lstn-https-httpd"
    backend_address_pool_name  = "${var.prefix}-gateway-subnet-beap-httpd"
    backend_http_settings_name = "${var.prefix}-gateway-subnet-be-htst-httpd"
  }

}
