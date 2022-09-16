# Pulic LB

resource "azurerm_public_ip" "tfrg" {
  name                = "${var.vmss_name}-pip"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  #domain_name_label   = var.rgname

  sku                 = "Standard"
}

resource "azurerm_public_ip" "tfrg_stage" {
  name                = "${var.vmss_name}-pip-stage"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  #domain_name_label   = var.rgname

  sku                 = "Standard"
}

resource "azurerm_lb" "tfrg" {
  name                = "${var.vmss_name}-lb"
  location            = var.location
  resource_group_name = var.rgname

  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.vmss_name}-pip"
    public_ip_address_id = azurerm_public_ip.tfrg.id
  }

  frontend_ip_configuration {
    name                 = "${var.vmss_name}-pip-stage"
    public_ip_address_id = azurerm_public_ip.tfrg_stage.id
  }

  tags = {
    ActiveSlot = "0"
  }
}

resource "azurerm_lb_rule" "tfrg" {
  //resource_group_name            = var.rgname
  loadbalancer_id                = azurerm_lb.tfrg.id
  name                           = "${var.vmss_name}-lbrule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.vmss_name}-pip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  probe_id                       = azurerm_lb_probe.tfrg.id
}

resource "azurerm_lb_rule" "tfrg_stage" {
  //resource_group_name            = var.rgname
  loadbalancer_id                = azurerm_lb.tfrg.id
  name                           = "${var.vmss_name}-lbrule-stage"
  protocol                       = "Tcp"
  frontend_port                  = 40080
  backend_port                   = 40080
  frontend_ip_configuration_name = "${var.vmss_name}-pip-stage"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  probe_id                       = azurerm_lb_probe.tfrg_stage.id
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  //resource_group_name = var.rgname
  loadbalancer_id     = azurerm_lb.tfrg.id
  name                = "${var.vmss_name}-bepool"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = var.rgname
  name                           = "RDP"
  loadbalancer_id                = azurerm_lb.tfrg.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 3389
  frontend_ip_configuration_name = "${var.vmss_name}-pip"
}

resource "azurerm_lb_nat_pool" "lbnatpool_stage" {
  resource_group_name            = var.rgname
  name                           = "RDP-stage"
  loadbalancer_id                = azurerm_lb.tfrg.id
  protocol                       = "Tcp"
  frontend_port_start            = 50200
  frontend_port_end              = 50219
  backend_port                   = 3389
  frontend_ip_configuration_name = "${var.vmss_name}-pip-stage"
}

resource "azurerm_lb_probe" "tfrg" {
  //resource_group_name = var.rgname
  loadbalancer_id     = azurerm_lb.tfrg.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = "/api/ping?slot=slot0"
  port                = 80
}

resource "azurerm_lb_probe" "tfrg_stage" {
  //resource_group_name = var.rgname
  loadbalancer_id     = azurerm_lb.tfrg.id
  name                = "http-probe-stage"
  protocol            = "Http"
  request_path        = "/api/ping?slot=slot1"
  port                = 40080
}

output "ip_address" {
  value = azurerm_public_ip.tfrg.ip_address
}

output "ip_stage_address" {
  value = azurerm_public_ip.tfrg_stage.ip_address
}