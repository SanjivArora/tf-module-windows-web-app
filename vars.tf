variable "create_resource_group" {
  description = "Whether to create resource group and use it for all resources"
  default     = false
  type        = bool
}

variable resource_group_name {
  type        = string
  default     = ""
  description = "Name of the Resource Group"
}

variable "location" {
  description = "The location/region to keep all your resources"
  default     = "australiaeast"
  type        = string
}

variable "location_short_ae" {
  description = "Short abbreviation of location"
  default     = "ae"
  type        = string
}

variable "environment" {
  description = "resources environment"
  default     = ""
  type        = string
}

## Log Analytics workspace
variable "create_log_analytics_workspace" {
  description = "Whether to create log analytics workspace and use it for all resources"
  default     = false
  type        = bool
}

variable log_analytics_workspace_name {
  type        = string
  default     = ""
  description = "Name of the log analytics workspace"
}

variable log_analytics_workspace_sku {
  type        = string
  default     = ""
  description = "Name of the log analytics workspace"
}

variable log_analytics_data_retention {
  type        = string
  default     = ""
  description = "Name of the log analytics workspace"
}

## Servcie Plan
variable "create_service_plan" {
  description = "Whether to create app service plan and use it for all resources"
  default     = false
  type        = bool
}

variable service_plan_name {
  type        = string
  default     = ""
  description = "Name of the service plan"
}

variable os_type {
  type        = string
  default     = "windows"
  description = "Type of OS for service plan, defaults to Windows. 'linux' and 'windows' are valid values"
}

variable service_plan_sku_name {
  type        = string
  default     = ""
  description = "Service plan sku name, valid values are "
}

## Application Insights
variable "create_application_insights" {
  description = "Whether to create app service plan and use it for all resources"
  default     = false
  type        = bool
}

variable application_insights_name {
  type        = string
  default     = ""
  description = "Name of the service plan"
}

variable application_insights_type {
  type        = string
  default     = "web"
  description = "Other valid option "
}

variable "application_insights_enabled" {
  description = "Use Application Insights for this App Service"
  type        = bool
  default     = true
}


## Service Plan
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

variable service_name {
  type        = string
  default     = ""
  description = "Name of the service or application"
}

variable solution {
  type        = string
  default     = ""
  description = "Name of the solution or application"
}

variable "app_service_vnet_integration_subnet_id" {
  description = "Id of the subnet to associate with the app service"
  type        = string
  default     = null
}

# variable "number_of_services" {
#   description = "Specify the number of services."
#   type        = number
#   default     = 1
# }

variable "common_tags" {
  description = "Common tags applied to all the resources created in this module"
  type        = map(string)
}

variable private_endpoint_name {
  type        = string
  default     = ""
  description = "Name of private enpoint"
}

variable private_endpoint_subnet_id {
  type        = string
  default     = ""
  description = "Private enpoint subnet ID"
}

variable webapp_private_dns_zone_id {
  type        = string
  default     = "/subscriptions/ca095a5d-36c0-4d4f-82ff-83580d85ebba/resourceGroups/sha-infra-dns-rg-ae-1/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
  description = "Private enpoint subnet ID"
}

variable "authorized_ips" {
  description = "IPs restriction for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#ip_restriction"
  type        = list(string)
  default     = []
}

variable "authorized_subnet_ids" {
  description = "Subnets restriction for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#ip_restriction"
  type        = list(string)
  default     = []
}

variable "authorized_service_tags" {
  description = "Service Tags restriction for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#ip_restriction"
  type        = list(string)
  default     = ["AzureDevOps"]
}

variable "ip_restriction_headers" {
  description = "IPs restriction headers for App Service. See documentation https://www.terraform.io/docs/providers/azurerm/r/app_service.html#headers"
  type        = map(list(string))
  default     = null
}