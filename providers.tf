terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    http = {
      source = "hashicorp/http"
    }
    random = {
      source = "hashicorp/random"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
