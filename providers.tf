terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = "us-east-2"
}

# Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "c8d10878-a32f-4f87-8f26-8871e5c95f99" 
  tenant_id       = "1ec9a7d8-fa35-434a-b015-fbd0827fe89d"
  client_id       = "8074e9ca-d22e-4a28-8363-c16716376b85" # appId from SP
  client_secret   =  var.client_secret #password from SP
}