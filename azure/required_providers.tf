terraform {
  required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = ">= 4.26.0"
  }
  azuread = {
    source  = "hashicorp/azuread"
    version = ">= 3.5.0"
  }
  tfe = {
    source  = "hashicorp/tfe"
    version = "~> 0.70.0"
  }
}
}
