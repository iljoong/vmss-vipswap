# VMSS
data "azurerm_user_assigned_identity" "tfmid" {
  name                = var.managedid_name
  resource_group_name = var.managedid_rgname
}

resource "azurerm_windows_virtual_machine_scale_set" "tfrg" {

  name                = "${var.vmss_name}-slot0"
  location            = var.location
  resource_group_name = var.rgname

  upgrade_mode        = "Automatic"
  automatic_os_upgrade_policy {
    disable_automatic_rollback  = true
    enable_automatic_os_upgrade = false
  }

  overprovision        = false

  sku                  = "Standard_D2as_v4"
  instances            = 2

  computer_name_prefix  = var.prefix
  admin_username        = var.admin_username
  admin_password        = var.admin_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    //disk_size_gb    = 128
  }

  source_image_id = var.image_uri
  /*source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "datacenter-core-1909-with-containers-smalldisk"
    version   = "latest"
  }*/

  extension {
    name                 = "CustomScriptExtension"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"
    auto_upgrade_minor_version = true
    settings             = "{}"
    protected_settings   = <<EOT
        {
          "fileUris": ["${var.blob_uri}script/setupiis.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File setupiis.ps1",
          "managedIdentity": { "clientId": "${data.azurerm_user_assigned_identity.tfmid.client_id}" }
        }
        EOT
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [ data.azurerm_user_assigned_identity.tfmid.id ]
  }

  network_interface {
    name    = "networkprofileslot0"
    primary = true

    ip_configuration {
      name                                   = "ipconfig-slot0"
      primary                                = true
      subnet_id                              = var.subnet_id #azurerm_subnet.tfdevvnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
    }
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "tfrg1" {

  name                = "${var.vmss_name}-slot1"
  location            = var.location
  resource_group_name = var.rgname

  upgrade_mode        = "Automatic"
  automatic_os_upgrade_policy {
    disable_automatic_rollback  = true
    enable_automatic_os_upgrade = false
  }

  overprovision        = false

  sku                  = "Standard_D2as_v4"
  instances            = 2

  computer_name_prefix  = var.prefix
  admin_username        = var.admin_username
  admin_password        = var.admin_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    //disk_size_gb    = 128
  }

  source_image_id = var.image_uri
  /*source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "datacenter-core-1909-with-containers-smalldisk"
    version   = "latest"
  }*/

  extension {
    name                 = "CustomScriptExtension"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"
    auto_upgrade_minor_version = true
    settings             = "{}"
    protected_settings   = <<EOT
        {
          "fileUris": ["${var.blob_uri}script/setupiis.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File setupiis.ps1",
          "managedIdentity": { "clientId": "${data.azurerm_user_assigned_identity.tfmid.client_id}" }
        }
        EOT
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [ data.azurerm_user_assigned_identity.tfmid.id ]
  }

  network_interface {
    name    = "networkprofileslot1"
    primary = true

    ip_configuration {
      name                                   = "ipconfig-slot1"
      primary                                = true
      subnet_id                              = var.subnet_id #azurerm_subnet.tfdevvnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool_stage.id]
    }
  }
}
