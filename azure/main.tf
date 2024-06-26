# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "TF-RG"
  location = "westeurope"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "tf-network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet_10-2-0-0_24"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.0.0/24"]
}


#resource "azurerm_virtual_network" "vnet2" {
#  name                = "tf-network2"
#  location            = azurerm_resource_group.rg.location
#  resource_group_name = azurerm_resource_group.rg.name
#  address_space       = ["10.2.0.0/16"]
#}

#resource "azurerm_subnet" "subnet2" {
#  name                 = "subnet_10-2-0-0_24"
#  resource_group_name  = azurerm_resource_group.rg.name
#  virtual_network_name = azurerm_virtual_network.vnet2.name
#  address_prefixes     = ["10.2.0.0/24"]
#}


resource "azurerm_route_table" "rt01" {
  name                          = "route-table-01"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "route-to-oracle"
    address_prefix = "10.99.0.0/16"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.2.0.5"
  }
}


resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.rt01.id
}