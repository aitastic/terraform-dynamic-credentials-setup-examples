output "subscription_id" {
  value = azurerm_subscription.main.subscription_id
}

output "service_principal_object_id" {
  value = azuread_service_principal.tfc_service_principal.object_id
}