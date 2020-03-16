# VMSS VM
resource "azurerm_virtual_machine_scale_set" "tfrg" {
  name                = "${var.vmss_name}-slot0"
  location            = var.location
  resource_group_name = var.rgname

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
    computer_name_prefix = var.prefix
    admin_username       = var.admin_username
    admin_password       = var.admin_password #data.azurerm_key_vault_secret.password.value
  }

  extension {
    name                 = "CustomScriptExtension"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"
    auto_upgrade_minor_version = true
    settings             = <<EOT
        {
          "fileUris": ["${var.blob_uri}script/setupiis.ps1"],
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
      subnet_id                              = var.subnet_id
      #load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      #load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
      application_gateway_backend_address_pool_ids = [azurerm_application_gateway.tfappgw.backend_address_pool[0].id]
    }
  }
}

resource "azurerm_virtual_machine_scale_set" "tfrg1" {
  name                = "${var.vmss_name}-slot1"
  location            = var.location
  resource_group_name = var.rgname

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
    computer_name_prefix = var.prefix
    admin_username       = var.admin_username
    admin_password       = var.admin_password #data.azurerm_key_vault_secret.password.value
  }

  extension {
    name                 = "CustomScriptExtension"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"
    auto_upgrade_minor_version = true
    settings             = <<EOT
        {
          "fileUris": ["${var.blob_uri}script/setupiis.ps1"],
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
      subnet_id                              = var.subnet_id
      #load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      #load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool_stage.id]
      application_gateway_backend_address_pool_ids = [azurerm_application_gateway.tfappgw.backend_address_pool[1].id]
    }
  }
}