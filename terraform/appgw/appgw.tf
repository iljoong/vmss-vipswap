# Reference:
#   https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html
#
resource "azurerm_public_ip" "tfappgw" {
  name                = "appgw-pip"
  resource_group_name = var.rgname
  location            = var.location
  allocation_method   = "Static"

  sku                 = "Standard"
}

resource "azurerm_application_gateway" "tfappgw" {
  name                = "${var.prefix}-appgw"
  resource_group_name = var.rgname
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = var.subnet_appgw_id
  }

  frontend_ip_configuration {
    name                 = "appgw-fe-ip"
    public_ip_address_id = azurerm_public_ip.tfappgw.id
  }

  probe {
      name                = "health-probe"
      protocol            = "http"
      host                = "127.0.0.1"
      path                = "/api/test"
      interval            = 15
      timeout             = 5
      unhealthy_threshold = 3
  }

  # rule - production
  request_routing_rule {
    name                       = "http-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http80"
    backend_address_pool_name  = "slot0"
    backend_http_settings_name = "http-settings"
  }

  http_listener {
    name                           = "http80"
    frontend_ip_configuration_name = "appgw-fe-ip"
    frontend_port_name             = "port80"
    protocol                       = "Http"
  }

  frontend_port {
    name = "port80"
    port = 80
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    #path                  = "/path1/"
    port                  = 80
    probe_name            = "health-probe"
    protocol              = "Http"
    request_timeout       = 5
  }

  backend_address_pool {
    name = "slot0"
  }

  # rule - stage
  request_routing_rule {
    name                       = "http-rule-stage"
    rule_type                  = "Basic"
    http_listener_name         = "http40080"
    backend_address_pool_name  = "slot1"
    backend_http_settings_name = "http-settings-stage"
  }

  http_listener {
    name                           = "http40080"
    frontend_ip_configuration_name = "appgw-fe-ip"
    frontend_port_name             = "port40080"
    protocol                       = "Http"
  }

  frontend_port {
    name = "port40080"
    port = 40080
  }

  backend_http_settings {
    name                  = "http-settings-stage"
    cookie_based_affinity = "Disabled"
    #path                  = "/path1/"
    port                  = 40080
    probe_name            = "health-probe"
    protocol              = "Http"
    request_timeout       = 5
  }

  backend_address_pool {
    name = "slot1"
  }
}

output "ip_address" {
  value = azurerm_public_ip.tfappgw.ip_address
}

output "ip_stage_address" {
  value = azurerm_public_ip.tfappgw.ip_address
}