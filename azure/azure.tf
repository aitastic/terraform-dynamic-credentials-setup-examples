# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

# Creates an application registration within Azure Active Directory.
#
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "tfc_application" {
  display_name = local.azure_app_registration_name

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

    resource_access {
      # Allow the application to manage Applications created by it
      id = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.OwnedBy"]
      type = "Role"
    }
  }
}


# Creates a service principal associated with the previously created
# application registration.
#
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal
resource "azuread_service_principal" "tfc_service_principal" {
  client_id = azuread_application.tfc_application.client_id
}

data "azurerm_billing_mca_account_scope" "main" {
  billing_account_name = var.billing_account_id
  billing_profile_name = var.billing_profile_id
  invoice_section_name = var.invoice_section_id
}

resource "azurerm_subscription" "main" {
  alias             = var.subscription_name
  subscription_name = var.subscription_name
  billing_scope_id  = data.azurerm_billing_mca_account_scope.main.id
}

# we have to fetch the subscription we just created in this same code...
# because azurerm_subscription.main.id is the id of the ALIAS, very questionable implementation
# but data.azurerm_subscription.main.id is the full subscription id which can be used in the scope parameter for role assignments
data "azurerm_subscription" "main" {
  subscription_id = azurerm_subscription.main.subscription_id
}

resource "azurerm_role_assignment" "subscription_owner" {
  for_each = toset(var.subscription_owners)

  scope                = data.azurerm_subscription.main.id
  principal_id         = each.value
  role_definition_name = "Owner"
}

# Creates a role assignment which controls the permissions the service
# principal has within the Azure subscription.
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "tfc_role_assignment_contributor" {
  scope                = data.azurerm_subscription.main.id
  principal_id         = azuread_service_principal.tfc_service_principal.object_id
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "tfc_role_assignment_rbac" {
  scope                = data.azurerm_subscription.main.id
  principal_id         = azuread_service_principal.tfc_service_principal.object_id
  role_definition_name = "Role Based Access Control Administrator"
}

# Creates a federated identity credential which ensures that the given
# workspace will be able to authenticate to Azure for the "plan" run phase.
#
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential
resource "azuread_application_federated_identity_credential" "tfc_federated_credential_plan" {
  application_id = azuread_application.tfc_application.id
  display_name   = "my-tfc-federated-credential-plan"
  audiences      = [var.tfc_azure_audience]
  issuer         = "https://${var.tfc_hostname}"
  subject        = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${local.tfc_workspace_name}:run_phase:plan"
}

# Creates a federated identity credential which ensures that the given
# workspace will be able to authenticate to Azure for the "apply" run phase.
#
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential
resource "azuread_application_federated_identity_credential" "tfc_federated_credential_apply" {
  application_id = azuread_application.tfc_application.id
  display_name   = "my-tfc-federated-credential-apply"
  audiences      = [var.tfc_azure_audience]
  issuer         = "https://${var.tfc_hostname}"
  subject        = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${local.tfc_workspace_name}:run_phase:apply"
}
