# ----------------------------------------------------------------------------------------------------------------------
# CAF resource
# ----------------------------------------------------------------------------------------------------------------------

module "azure_region" {
  source       = "git::git@github.com:kaganmersin/pit-infra.git//modules/regions?ref=feat/initial-modules"
  azure_region = var.az_region
}

# ----------------------------------------------------------------------------------------------------------------------
# Log analytics workspace
# ----------------------------------------------------------------------------------------------------------------------

resource "azurerm_service_plan" "default" {
  count                        = var.create ? 1 : 0
  name                         = join(var.delimiter, compact([local.stage_prefix, var.prefix, module.azure_region.location_short, var.name]))
  location                     = module.azure_region.location_cli
  resource_group_name          = var.resource_group_name
  os_type                      = var.os_type
  sku_name                     = var.sku_name
  zone_balancing_enabled       = var.zone_balancing_enabled
  worker_count                 = var.sku_name == "Y1" ? null : var.worker_count
  maximum_elastic_worker_count = can(regex("E1|E2|E3", var.sku_name)) ? var.maximum_elastic_worker_count : null
  app_service_environment_id   = var.app_service_environment_id
  per_site_scaling_enabled     = var.per_site_scaling_enabled
  tags                         = local.tags
}


module "diagnostic" {
  count                 = var.create && var.logs_destinations_ids != [] ? 1 : 0
  source                = "git::git@github.com:kaganmersin/pit-infra.git//modules/diagnostic?ref=feat/initial-modules"
  namespace             = var.namespace
  environment           = var.environment
  stage                 = var.stage
  application           = var.application
  az_region             = var.az_region
  target_resource_id    = concat(azurerm_service_plan.default.*.id, [""])[0]
  logs_destinations_ids = var.logs_destinations_ids
}
