output "service_plan_id" {
  description = "ID of the created Service Plan"
  value       = concat(azurerm_service_plan.default.*.id, [""])[0]
}