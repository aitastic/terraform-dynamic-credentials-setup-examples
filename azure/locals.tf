locals {
  tfc_workspace_name = "azure-${var.subscription_name}"
  azure_app_registration_name = "terraform-sp-${var.subscription_name}"
}