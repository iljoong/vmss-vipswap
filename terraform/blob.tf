# Storage account & Blob
# https://www.terraform.io/docs/providers/azurerm/r/storage_blob.html
# https://www.terraform.io/docs/providers/azurerm/r/storage_container.html
# https://www.terraform.io/docs/providers/azurerm/r/storage_management_policy.html

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
  container_access_type = "private" //"blob"
}

resource "azurerm_storage_blob" "tfblob_script" {
  name = "setupiis.ps1"

  storage_account_name   = azurerm_storage_account.tfblob.name
  storage_container_name = azurerm_storage_container.tfblob.name

  type   = "Block"
  source = "./script/setupiis.ps1"
}

resource "azurerm_storage_container" "tfblobapp" {
  name                  = "app"
  storage_account_name  = azurerm_storage_account.tfblob.name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "tfblob" {
  storage_account_id = azurerm_storage_account.tfblob.id

  rule {
    name    = "appretention"
    enabled = true
    filters {
      prefix_match = ["app/app"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 3
      }
    }
  }
}

output "blob_endpoint" {
  value = azurerm_storage_account.tfblob.primary_blob_endpoint
}