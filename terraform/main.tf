module "vmss" {
    source    = "./plb" # ["./appgw", "./plb", "./ilb"]
    rgname    = azurerm_resource_group.tfrg.name
    location  = var.location

    prefix         = var.prefix
    vmss_name      = var.vmss_name
    admin_username = var.admin_username
    admin_password = data.azurerm_key_vault_secret.password.value
    image_uri      = var.image_uri

    blob_uri        = azurerm_storage_account.tfblob.primary_blob_endpoint
    
    subnet_id       = azurerm_subnet.tfdevvnet.id
    subnet_appgw_id = azurerm_subnet.tfappgwvnet.id
}

data "azurerm_key_vault_secret" "password" {
  name          = "adminpassword"
  key_vault_id  = var.vault_id
}

output "ip" {
    value = "${module.vmss.ip_address}"
}

output "ip_stage" {
    value = "${module.vmss.ip_stage_address}:40080"
}