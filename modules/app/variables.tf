# ----------------------------------------------------------------------------------------------------------------------
# Module Standard Variables
# ----------------------------------------------------------------------------------------------------------------------

variable "name" {
  type        = string
  default     = "app"
  description = "The name of the module"
}

variable "terraform_module" {
  type        = string
  default     = "kaganmersin/pit-infra/modules/app"
  description = "The owner and name of the Terraform module"
}

variable "az_region" {
  type        = string
  default     = ""
  description = "The Azure region to deploy module into"
}

variable "resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the Azure resource group"
}

variable "create" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

# ----------------------------------------------------------------------------------------------------------------------
# Platform Standard Variables
# ----------------------------------------------------------------------------------------------------------------------

# Recommended

variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be your organization abbreviation, client name, etc. (e.g. Pet-Insurance 'pit', HashiCorp 'hc')"
}

variable "environment" {
  type        = string
  default     = ""
  description = "The isolated environment the module is associated with (e.g. Shared Services `shared`, Application `app`)"
}

variable "stage" {
  type        = string
  default     = ""
  description = "The development stage (i.e. `dev`, `stg`, `prd`)"
}

variable "application" {
  type        = string
  default     = ""
  description = "The application name (i.e. `apex`, `portal`)"
}

variable "repository" {
  type        = string
  default     = ""
  description = "The repository where the code referencing the module is stored"
}

# Optional

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional map of tags (e.g. business_unit, cost_center)"
}

variable "desc_prefix" {
  type        = string
  default     = "Pi:"
  description = "The prefix to add to any descriptions attached to resources"
}

variable "environment_prefix" {
  type        = string
  default     = ""
  description = "Concatenation of `namespace` and `environment`"
}

variable "stage_prefix" {
  type        = string
  default     = ""
  description = "Concatenation of `namespace`, `environment` and `stage`"
}

variable "module_prefix" {
  type        = string
  default     = ""
  description = "Concatenation of `namespace`, `environment`, `stage` and `name`"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `environment`, `stage`, `name`"
}

variable "prefix" {
  type        = string
  default     = null
  description = "The prefix to add to the name of the resources"
}

locals {
  environment_prefix = coalesce(var.environment_prefix, join(var.delimiter, compact([var.namespace, var.environment])))
  stage_prefix       = coalesce(var.stage_prefix, join(var.delimiter, compact([local.environment_prefix, var.stage])))
  module_prefix      = coalesce(var.module_prefix, join(var.delimiter, compact([local.stage_prefix, var.application, module.azure_region.location_short, var.name])))

  business_tags = {
    namespace          = var.namespace
    environment        = var.environment
    environment_prefix = local.environment_prefix
  }
  technical_tags = {
    stage      = var.stage
    module     = var.name
    repository = var.repository
    region     = var.az_region
  }
  automation_tags = {
    terraform_module = var.terraform_module
    stage_prefix     = local.stage_prefix
    module_prefix    = local.module_prefix
  }
  security_tags = {}

  tags = merge(
    local.business_tags,
    local.technical_tags,
    local.automation_tags,
    local.security_tags,
    var.tags
  )
}


# ----------------------------------------------------------------------------------------------------------------------
# Module variables
# ----------------------------------------------------------------------------------------------------------------------


variable "service_plan_id" {
  description = "ID of the Service Plan that hosts the App Service"
  type        = string
}

variable "application_insights_sampling_percentage" {
  description = "Specifies the percentage of sampled datas for Application Insights. Documentation [here](https://docs.microsoft.com/en-us/azure/azure-monitor/app/sampling#ingestion-sampling)"
  type        = number
  default     = null
}

variable "application_insights_id" {
  description = "ID of the existing Application Insights to use instead of deploying a new one."
  type        = string
  default     = null
}

variable "application_insights_enabled" {
  description = "Use Application Insights for this App Service"
  type        = bool
  default     = true
}

variable "application_insights_type" {
  description = "Application type for Application Insights resource"
  type        = string
  default     = "web"
}

variable "app_settings" {
  description = "Application settings for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#app_settings"
  type        = map(string)
  default     = {}
}

variable "site_config" {
  description = "Site config for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#site_config. IP restriction attribute is no more managed in this block."
  type        = any
  default     = {}
}

variable "connection_strings" {
  description = "Connection strings for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#connection_string"
  type        = list(map(string))
  default     = []
}

variable "sticky_settings" {
  description = "Lists of connection strings and app settings to prevent from swapping between slots."
  type = object({
    app_setting_names       = optional(list(string))
    connection_string_names = optional(list(string))
  })
  default = null
}

variable "authorized_ips" {
  description = "IPs restriction for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#ip_restriction"
  type        = list(string)
  default     = []
}

variable "public_network_access_enabled" {
  description = "Whether enable public access for the App Service."
  type        = bool
  default     = false
}

variable "authorized_subnet_ids" {
  description = "Subnets restriction for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#ip_restriction"
  type        = list(string)
  default     = []
}

variable "authorized_service_tags" {
  description = "Service Tags restriction for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#ip_restriction"
  type        = list(string)
  default     = []
}

variable "ip_restriction_headers" {
  description = "IPs restriction headers for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#headers"
  type        = map(list(string))
  default     = null
}

variable "scm_authorized_ips" {
  description = "SCM IPs restriction for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#scm_ip_restriction"
  type        = list(string)
  default     = []
}

variable "scm_authorized_subnet_ids" {
  description = "SCM subnets restriction for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#scm_ip_restriction"
  type        = list(string)
  default     = []
}

variable "scm_authorized_service_tags" {
  description = "SCM Service Tags restriction for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#scm_ip_restriction"
  type        = list(string)
  default     = []
}

variable "scm_ip_restriction_headers" {
  description = "IPs restriction headers for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#headers"
  type        = map(list(string))
  default     = null
}

variable "client_affinity_enabled" {
  description = "Client affinity activation for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#client_affinity_enabled"
  type        = bool
  default     = false
}

variable "https_only" {
  description = "HTTPS restriction for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#https_only"
  type        = bool
  default     = false
}

variable "client_certificate_enabled" {
  description = "Client certificate activation for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#client_certificate_enabled"
  type        = bool
  default     = false
}

variable "enabled" {
  description = "Enable the App Service"
  type        = bool
  default     = true
}

# Backup options

variable "backup_enabled" {
  description = "`true` to enable App Service backup"
  type        = bool
  default     = false
}

variable "backup_storage_account_url" {
  description = "Storage account URL to use if App Service backup is enabled."
  type        = string
  default     = null
}

variable "backup_frequency_interval" {
  description = "Frequency interval for the App Service backup."
  type        = number
  default     = 1
}

variable "backup_retention_period_in_days" {
  description = "Retention in days for the App Service backup."
  type        = number
  default     = 30
}

variable "backup_frequency_unit" {
  description = "Frequency unit for the App Service backup. Possible values are `Day` or `Hour`."
  type        = string
  default     = "Day"
}

variable "backup_keep_at_least_one_backup" {
  description = "Should the service keep at least one backup, regardless of age of backup."
  type        = bool
  default     = true
}

variable "backup_storage_account_rg" {
  description = "Storage account resource group to use if App Service backup is enabled."
  type        = string
  default     = null
}

variable "backup_storage_account_name" {
  description = "Storage account name to use if App Service backup is enabled."
  type        = string
  default     = null
}

variable "backup_storage_account_container" {
  description = "Name of the container in the Storage Account if App Service backup is enabled"
  type        = string
  default     = "webapps"
}

variable "mount_points" {
  description = "Storage Account mount points. Name is generated if not set and default type is AzureFiles. See https://www.terraform.io/docs/providers/azurerm/r/app_service.html#storage_account"
  type        = list(map(string))
  default     = []
}

variable "auth_settings" {
  description = "Authentication settings. Issuer URL is generated thanks to the tenant ID. For active_directory block, the allowed_audiences list is filled with a value generated with the name of the App Service. See https://www.terraform.io/docs/providers/azurerm/r/app_service.html#auth_settings"
  type        = any
  default     = {}
}

variable "auth_settings_v2" {
  description = "Authentication settings V2. See https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app#auth_settings_v2"
  type        = any
  default     = {}
}

variable "custom_domains" {
  description = <<EOD
Custom domains and SSL certificates of the App Service. Could declare a custom domain with SSL binding. SSL certificate could be provided from an Azure Keyvault Certificate Secret or from a file with following attributes :
```
- certificate_name:                     Name of the stored certificate.
- certificate_keyvault_certificate_id:  ID of the Azure Keyvault Certificate Secret.
```
EOD
  type = map(object({
    certificate_name                    = optional(string)
    certificate_keyvault_certificate_id = optional(string)
    certificate_thumbprint              = optional(string)
  }))
  default  = {}
  nullable = false
}

variable "certificates" {
  description = "Certificates for custom domains"
  type        = map(map(string))
  default     = {}
}

variable "app_service_vnet_integration_subnet_id" {
  description = "Id of the subnet to associate with the app service"
  type        = string
  default     = null
}

variable "staging_slot_enabled" {
  type        = bool
  description = "Create a staging slot alongside the app service for blue/green deployment purposes. See documentation https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_slot"
  default     = true
}

variable "staging_slot_custom_app_settings" {
  type        = map(string)
  description = "Override staging slot with custom app settings"
  default     = null
}

variable "app_service_logs" {
  description = "Configuration of the App Service and App Service Slot logs. Documentation [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app#logs)"
  type = object({
    detailed_error_messages = optional(bool)
    failed_request_tracing  = optional(bool)
    application_logs = optional(object({
      file_system_level = string
      azure_blob_storage = optional(object({
        level             = string
        retention_in_days = number
        sas_url           = string
      }))
    }))
    http_logs = optional(object({
      azure_blob_storage = optional(object({
        retention_in_days = number
        sas_url           = string
      }))
      file_system = optional(object({
        retention_in_days = number
        retention_in_mb   = number
      }))
    }))
  })
  default = null
}

variable "identity" {
  description = "Map with identity block information."
  type = object({
    type         = string
    identity_ids = list(string)
  })
  default = {
    type         = "SystemAssigned"
    identity_ids = []
  }
}

variable "staging_slot_site_config" {
  description = "Staging slot site config for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#site_config."
  type        = any
  default     = {}
}

variable "staging_slot_connection_strings" {
  description = "Connection strings for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#connection_string"
  type        = list(map(string))
  default     = []
}

variable "staging_slot_name_abbreviation" {
  description = "Abbreviation for the staging slot name"
  type        = string
  default     = "stsn"
}