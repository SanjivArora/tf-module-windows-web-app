output "instrumentation_key" {
  sensitive = true
  value = azurerm_application_insights.app_insights[*].instrumentation_key
}

output "app_id" {
  value = azurerm_application_insights.app_insights[*].app_id
}

output "app_service_site_hostname" {
  description = "The Default Hostname associated with the App Service"
  value       = azurerm_windows_web_app.this_service.default_hostname
}

output "app_user_assigned_identity_object_id" {
  value = azurerm_user_assigned_identity.app_user_identity.principal_id
}