terraform {
  required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = "~> 3.66.0"
  }
  azuread = {
    source  = "hashicorp/azuread"
    version = "~> 3.6.0"
  }
  tfe = {
    source  = "hashicorp/tfe"
    version = "~> 0.70.0"
  }
}
}
