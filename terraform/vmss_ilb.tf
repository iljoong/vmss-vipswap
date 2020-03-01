data "azurerm_key_vault_secret" "password" {
  name          = "adminpassword"
  key_vault_id  = var.vault_id
}

/*
resource "azurerm_public_ip" "tfrg" {
  name                = "${var.vmss_name}-pip"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name
  allocation_method   = "Static"
  #domain_name_label   = azurerm_resource_group.tfrg.name

  sku                 = "Standard"
}

resource "azurerm_public_ip" "tfrg_stage" {
  name                = "${var.vmss_name}-pip-stage"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name
  allocation_method   = "Static"
  #domain_name_label   = azurerm_resource_group.tfrg.name

  sku                 = "Standard"
}
*/

resource "azurerm_lb" "tfrg" {
  name                = "${var.vmss_name}-lb"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name

  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.vmss_name}-ip"
    #public_ip_address_id = azurerm_public_ip.tfrg.id
    private_ip_address_allocation = "Static"
    subnet_id                     = azurerm_subnet.tfdevvnet.id
    private_ip_address            = "10.1.1.100"
  }

  frontend_ip_configuration {
    name                 = "${var.vmss_name}-ip-stage"
    #public_ip_address_id = azurerm_public_ip.tfrg_stage.id
    private_ip_address_allocation = "Static"
    subnet_id                     = azurerm_subnet.tfdevvnet.id
    private_ip_address            = "10.1.1.101"
  }

  tags = {
    ActiveSlot = "0"
  }
}

resource "azurerm_lb_rule" "tfrg" {
  resource_group_name            = azurerm_resource_group.tfrg.name
  loadbalancer_id                = azurerm_lb.tfrg.id
  name                           = "${var.vmss_name}-lbrule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.tfrg.frontend_ip_configuration[0].name #"${var.vmss_name}-ip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  probe_id                       = azurerm_lb_probe.tfrg.id
}

resource "azurerm_lb_rule" "tfrg_stage" {
  resource_group_name            = azurerm_resource_group.tfrg.name
  loadbalancer_id                = azurerm_lb.tfrg.id
  name                           = "${var.vmss_name}-lbrule-stage"
  protocol                       = "Tcp"
  frontend_port                  = 40080
  backend_port                   = 40080
  frontend_ip_configuration_name = azurerm_lb.tfrg.frontend_ip_configuration[1].name #"${var.vmss_name}-pip-stage"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  probe_id                       = azurerm_lb_probe.tfrg_stage.id
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = azurerm_resource_group.tfrg.name
  loadbalancer_id     = azurerm_lb.tfrg.id
  name                = "${var.vmss_name}-bepool"
}

/*
resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = azurerm_resource_group.tfrg.name
  name                           = "RDP"
  loadbalancer_id                = azurerm_lb.tfrg.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 3389
  frontend_ip_configuration_name = "${var.vmss_name}-pip"
}

resource "azurerm_lb_nat_pool" "lbnatpool_stage" {
  resource_group_name            = azurerm_resource_group.tfrg.name
  name                           = "RDP-stage"
  loadbalancer_id                = azurerm_lb.tfrg.id
  protocol                       = "Tcp"
  frontend_port_start            = 50200
  frontend_port_end              = 50219
  backend_port                   = 3389
  frontend_ip_configuration_name = "${var.vmss_name}-pip-stage"
}
*/

resource "azurerm_lb_probe" "tfrg" {
  resource_group_name = azurerm_resource_group.tfrg.name
  loadbalancer_id     = azurerm_lb.tfrg.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = "/api/ping?slot=slot0"
  port                = 80
}

resource "azurerm_lb_probe" "tfrg_stage" {
  resource_group_name = azurerm_resource_group.tfrg.name
  loadbalancer_id     = azurerm_lb.tfrg.id
  name                = "http-probe-stage"
  protocol            = "Http"
  request_path        = "/api/ping?slot=slot1"
  port                = 40080
}
