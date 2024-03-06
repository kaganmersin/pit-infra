# ----------------------------------------------------------------------------------------------------------------------
# CAF resource
# ----------------------------------------------------------------------------------------------------------------------


module "azure_region" {
  # source       = "git::git@github.com:kaganmersin/pit-infra.git//modules/regions?ref=0.1.0"
  source       = "./modules/regions"
  azure_region = var.az_region
}


# ----------------------------------------------------------------------------------------------------------------------
# Resource Group resource
# ----------------------------------------------------------------------------------------------------------------------


resource "azurerm_resource_group" "default" {
  for_each = var.create ? var.resource_groups : {}
  name     = join(var.delimiter, compact([local.stage_prefix, var.application, module.azure_region.location_short, each.value.prefix, var.name]))
  location = var.az_region
  tags     = local.tags
}

resource "azurerm_management_lock" "default" {
  for_each = {
    for key, rg in var.resource_groups : key => rg
    if rg.lock_level != null && rg.lock_level != ""
  }
  name       = join(var.delimiter, [azurerm_resource_group.default[each.key].name, "lock"])
  scope      = azurerm_resource_group.default[each.key].id
  lock_level = each.value.lock_level
  notes      = "Resource Group '${azurerm_resource_group.default[each.key].name}' is locked with '${each.value.lock_level}' level."
}

