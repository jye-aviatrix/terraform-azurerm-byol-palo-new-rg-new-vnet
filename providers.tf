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
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
