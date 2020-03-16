# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "tfrg" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = {
    environment = var.tag
  }
}

# Create virtual network
resource "azurerm_virtual_network" "tfvnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.tfrg.name

  tags = {
    environment = var.tag
  }
}

resource "azurerm_subnet" "tfdevvnet" {
  name                 = "dev-subnet"
  virtual_network_name = azurerm_virtual_network.tfvnet.name
  resource_group_name  = azurerm_resource_group.tfrg.name
  address_prefix       = "10.1.1.0/24"
  
  # this is temporary: https://www.terraform.io/docs/providers/azurerm/r/subnet_network_security_group_association.html
  #network_security_group_id = azurerm_network_security_group.tfnsg.id
}

resource "azurerm_subnet" "tfprdvnet" {
  name                 = "prd-subnet"
  virtual_network_name = azurerm_virtual_network.tfvnet.name
  resource_group_name  = azurerm_resource_group.tfrg.name
  address_prefix       = "10.1.2.0/24"
}

resource "azurerm_subnet" "tfagtvnet" {
  name                 = "agt-subnet"
  virtual_network_name = azurerm_virtual_network.tfvnet.name
  resource_group_name  = azurerm_resource_group.tfrg.name
  address_prefix       = "10.1.3.0/24"
}

resource "azurerm_subnet" "tfappgwvnet" {
  name                 = "appgw-subnet"
  virtual_network_name = azurerm_virtual_network.tfvnet.name
  resource_group_name  = azurerm_resource_group.tfrg.name
  address_prefix       = "10.1.0.0/24"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "tfnsg" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.tfrg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP_stage"
    priority                   = 2100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "40080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "tfdevvnet" {
  subnet_id                 = azurerm_subnet.tfdevvnet.id
  network_security_group_id = azurerm_network_security_group.tfnsg.id
}

/*
# user assinged identity
resource "azurerm_user_assigned_identity" "tfrg" {
  resource_group_name = azurerm_resource_group.tfrg.name
  location            = azurerm_resource_group.tfrg.location

  name = "devopsidentity"
}
*/