# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "tfe" {
  hostname = var.tfc_hostname
}

# Runs in this workspace will be automatically authenticated
# to Azure with the permissions set in the Azure policy. TODO: che k if wording right
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace
resource "tfe_workspace" "my_workspace" {
  name         = local.tfc_workspace_name
  organization = var.tfc_organization_name
  project_id   = var.tfc_project_id

  vcs_repo {
    identifier     = var.tfc_vcs_repo_identifier
    oauth_token_id = var.tfc_vcs_oauth_token_id
  }

  working_directory = var.tfc_workspace_working_directory
  trigger_prefixes  = var.tfc_workspace_trigger_prefixes
}

# The following variables must be set to allow runs
# to authenticate to Azyre.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_azure_provider_auth" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_AZURE_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for Azure."
}

resource "tfe_variable" "tfc_azure_client_id" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "TFC_AZURE_RUN_CLIENT_ID"
  value    = azuread_application.tfc_application.application_id
  category = "env"

  description = "The Azure Client ID runs will use to authenticate."
}

resource "tfe_variable" "arm_client_id" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "ARM_CLIENT_ID"
  value    = azuread_application.tfc_application.application_id
  category = "env"

  description = "The Azure Client ID Terraform will use to authenticate."
}

resource "tfe_variable" "arm_tenant_id" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "ARM_TENANT_ID"
  value    = azurerm_subscription.main.tenant_id
  category = "env"

  description = "The Azure Tenant ID Terraform will use to authenticate."
}

resource "tfe_variable" "arm_subscription_id" {
  workspace_id = tfe_workspace.my_workspace.id

  key      = "ARM_SUBSCRIPTION_ID"
  value    = azurerm_subscription.main.subscription_id
  category = "env"

  description = "The Azure Subscription ID Terraform will use to authenticate."
}

# The following variables are optional; uncomment the ones you need!

# resource "tfe_variable" "tfc_azure_audience" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_AZURE_WORKLOAD_IDENTITY_AUDIENCE"
#   value    = var.tfc_azure_audience
#   category = "env"

#   description = "The value to use as the audience claim in run identity tokens"
# }
