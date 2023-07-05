# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "tfc_azure_audience" {
  type        = string
  default     = "api://AzureADTokenExchange"
  description = "The audience value to use in run identity tokens"
}

variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE instance you'd like to use with Azure"
}

variable "tfc_organization_name" {
  type        = string
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_project_name" {
  type        = string
  default     = "Azure"
  description = "The project under which a workspace will be created"
}

variable "subscription_name" {
  type        = string
  description = "The name of the new Azure subscription that will be created"
}

variable "billing_account_id" {
  type        = string
  description = "The billing account id for the billing scope under which the created Subscription will be billed"
}

variable "billing_profile_id" {
  type        = string
  description = "The billing profile id for the billing scope under which the created Subscription will be billed"
}

variable "invoice_section_id" {
  type        = string
  description = "The invoice section id for the billing scope under which the created Subscription will be billed"
}