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

resource "azurerm_lb" "tfrg" {
  name                = "${var.vmss_name}-lb"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name

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
  resource_group_name            = azurerm_resource_group.tfrg.name
  loadbalancer_id                = azurerm_lb.tfrg.id
  name                           = "${var.vmss_name}-lbrule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.vmss_name}-pip"
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
  frontend_ip_configuration_name = "${var.vmss_name}-pip-stage"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  probe_id                       = azurerm_lb_probe.tfrg_stage.id
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = azurerm_resource_group.tfrg.name
  loadbalancer_id     = azurerm_lb.tfrg.id
  name                = "${var.vmss_name}-bepool"
}

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

resource "azurerm_virtual_machine_scale_set" "tfrg" {
  name                = "${var.vmss_name}-slot0"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name

  automatic_os_upgrade = false
  upgrade_policy_mode  = "Automatic"

  overprovision        = false

  sku {
    name     = "Standard_D2s_v3"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    os_type           = "windows"
    managed_disk_type = "Premium_LRS"
  }

  storage_profile_image_reference {
    id                = var.image_uri
  }

  os_profile {
    computer_name_prefix = "vmss"
    admin_username       = "iljoong"
    admin_password       = "Ilkim*202001"
  }

  extension {
    name                 = "CustomScriptExtension"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"
    auto_upgrade_minor_version = true
    settings             = <<EOT
        {
          "fileUris": ["${azurerm_storage_account.tfblob.primary_blob_endpoint}script/setupiis.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File setupiis.ps1"
        }
        EOT
  }

  network_profile {
    name    = "networkprofileslot0"
    primary = true

    ip_configuration {
      name                                   = "ipconfig-slot0"
      primary                                = true
      subnet_id                              = azurerm_subnet.tfdevvnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
    }
  }
}

resource "azurerm_virtual_machine_scale_set" "tfrg1" {
  name                = "${var.vmss_name}-slot1"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name

  automatic_os_upgrade = false
  upgrade_policy_mode  = "Automatic"

  overprovision        = false

  sku {
    name     = "Standard_D2s_v3"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    os_type           = "windows"
    managed_disk_type = "Premium_LRS"
  }

  storage_profile_image_reference {
    id                = var.image_uri
  }

  os_profile {
    computer_name_prefix = "vmss"
    admin_username       = "iljoong"
    admin_password       = "Ilkim*202001"
  }

  extension {
    name                 = "CustomScriptExtension"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"
    auto_upgrade_minor_version = true
    settings             = <<EOT
        {
          "fileUris": ["${azurerm_storage_account.tfblob.primary_blob_endpoint}script/setupiis.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File setupiis.ps1"
        }
        EOT                    
  }

  network_profile {
    name    = "networkprofileslot1"
    primary = true

    ip_configuration {
      name                                   = "ipconfig-slot1"
      primary                                = true
      subnet_id                              = azurerm_subnet.tfdevvnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool_stage.id]
    }
  }
  
}

output "pip_address" {
  value = azurerm_public_ip.tfrg.ip_address
}

output "pip_stage_address" {
  value = azurerm_public_ip.tfrg_stage.ip_address
}