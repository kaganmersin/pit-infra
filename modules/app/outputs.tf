output "service_plan_id" {
  description = "ID of the Service Plan"
  value       = var.service_plan_id
}

output "app_service_id" {
  description = "Id of the App Service"
  value       = azurerm_windows_web_app.default.id
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_windows_web_app.default.name
}

output "app_service_default_site_hostname" {
  description = "The Default Hostname associated with the App Service"
  value       = azurerm_windows_web_app.default.default_hostname
}

output "app_service_outbound_ip_addresses" {
  description = "Outbound IP adresses of the App Service"
  value       = split(",", azurerm_windows_web_app.default.outbound_ip_addresses)
}

output "app_service_possible_outbound_ip_addresses" {
  description = "Possible outbound IP adresses of the App Service"
  value       = split(",", azurerm_windows_web_app.default.possible_outbound_ip_addresses)
}

output "app_service_site_credential" {
  description = "Site credential block of the App Service"
  value       = azurerm_windows_web_app.default.site_credential
}

output "app_service_identity_service_principal_id" {
  description = "Id of the Service principal identity of the App Service"
  value       = azurerm_windows_web_app.default.identity[0].principal_id
}

output "app_service_slot_name" {
  description = "Name of the App Service slot"
  value       = try(azurerm_windows_web_app_slot.default_slot[0].name, null)
}

output "app_service_slot_identity_service_principal_id" {
  description = "Id of the Service principal identity of the App Service slot"
  value       = try(azurerm_windows_web_app_slot.default_slot[0].identity[0].principal_id, null)
}

output "app_service_certificates_id" {
  description = "ID of certificates generated."
  value       = { for k, v in var.custom_domains : k => azurerm_app_service_certificate.app_service_certificate[k].id if try(v.certificate_id == null, false) }
}