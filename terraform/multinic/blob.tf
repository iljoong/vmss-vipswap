# Storage account & Blob
resource "azurerm_storage_account" "tfblob" {
  name                     = "${var.prefix}blobacct"
  resource_group_name      = azurerm_resource_group.tfrg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = {
    environment = var.tag
  }
}

resource "azurerm_storage_container" "tfblob" {
  name                  = "script"
  storage_account_name  = azurerm_storage_account.tfblob.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "tfblob_script" {
  name = "setup.ps1"

  storage_account_name   = azurerm_storage_account.tfblob.name
  storage_container_name = azurerm_storage_container.tfblob.name

  type   = "block"
  source = "./script/setup.ps1"
}

output "blob_endpoint" {
  value = azurerm_storage_account.tfblob.primary_blob_endpoint
}