#-------------------------------
# Local Declarations
#-------------------------------
locals {
  resource_group_name      = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location                 = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  log_analytics_workspace_name      = element(coalescelist(data.azurerm_log_analytics_workspace.logs_workspace.*.name, azurerm_log_analytics_workspace.logs_workspace.*.name, [""]), 0)
  log_analytics_workspace_id    = element(coalescelist(data.azurerm_log_analytics_workspace.logs_workspace.*.id, azurerm_log_analytics_workspace.logs_workspace.*.id, [""]), 0)
  service_plan_name             = element(coalescelist(data.azurerm_service_plan.this_plan.*.name, azurerm_service_plan.this_plan.*.name, [""]), 0)
  service_plan_id             = element(coalescelist(data.azurerm_service_plan.this_plan.*.id, azurerm_service_plan.this_plan.*.id, [""]), 0)
 
 
   app_insights = try(data.azurerm_application_insights.app_insights[0], try(azurerm_application_insights.app_insights[0], {}))
   
   default_app_settings = var.application_insights_enabled ? {
    APPLICATION_INSIGHTS_IKEY             = try(local.app_insights.instrumentation_key, "")
    APPINSIGHTS_INSTRUMENTATIONKEY        = try(local.app_insights.instrumentation_key, "")
    APPLICATIONINSIGHTS_CONNECTION_STRING = try(local.app_insights.connection_string, "")
  } : {}

  app_settings = merge(local.default_app_settings, var.app_settings)

   default_site_config = {
    always_on = "true"
    scm_minimum_tls_version = "1.2"
   }
  site_config = merge(local.default_site_config, var.site_config)

  # cidrs = [for cidr in var.authorized_ips : {
  #   name                      = "ip_restriction_cidr_${join("", [1, index(var.authorized_ips, cidr)])}"
  #   ip_address                = cidr
  #   virtual_network_subnet_id = null
  #   service_tag               = null
  #   subnet_id                 = null
  #   priority                  = join("", [1, index(var.authorized_ips, cidr)])
  #   action                    = "Allow"
  #   # headers                   = local.ip_restriction_headers
  # }]

  # subnets = [for subnet in var.authorized_subnet_ids : {
  #   name                      = "ip_restriction_subnet_${join("", [1, index(var.authorized_subnet_ids, subnet)])}"
  #   ip_address                = null
  #   virtual_network_subnet_id = subnet
  #   service_tag               = null
  #   subnet_id                 = subnet
  #   priority                  = join("", [1, index(var.authorized_subnet_ids, subnet)])
  #   action                    = "Allow"
  #   # headers                   = local.ip_restriction_headers
  # }]
  default_ip_restrictions_headers = {
    x_azure_fdid      = null
    x_fd_health_probe = null
    x_forwarded_for   = null
    x_forwarded_host  = null
  }

  ip_restriction_headers = var.ip_restriction_headers != null ? [merge(local.default_ip_restrictions_headers, var.ip_restriction_headers)] : []

  service_tags = [for service_tag in var.authorized_service_tags : {
    name                      = "service_tag_restriction_${join("", [1, index(var.authorized_service_tags, service_tag)])}"
    ip_address                = null
    virtual_network_subnet_id = null
    service_tag               = service_tag
    subnet_id                 = null
    priority                  = join("", [1, index(var.authorized_service_tags, service_tag)])
    action                    = "Allow"
    headers                   = local.ip_restriction_headers
  }]

 }


#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------

data "azurerm_resource_group" "rgrp" {
    count = var.create_resource_group == false ? 1 : 0
    name = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = merge(
  var.common_tags, { 
  Name = format("%s", var.resource_group_name) 
  }
  )
}

#---------------------------------------------------------
# Log Analytics workspace Creation or selection - Default is "false"
#----------------------------------------------------------

data "azurerm_log_analytics_workspace" "logs_workspace" {
    count = var.create_log_analytics_workspace == false ? 1 : 0
    name = var.log_analytics_workspace_name
    resource_group_name = local.resource_group_name
}

resource "azurerm_log_analytics_workspace" "logs_workspace" {
  count    = var.create_log_analytics_workspace ? 1 : 0
  name     = lower(var.log_analytics_workspace_name)
  resource_group_name = local.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_data_retention
  location = local.location
  tags     = merge(
  var.common_tags, { 
  Name = format("%s", var.log_analytics_workspace_name) 
  }
  )
}

#---------------------------------------------------------
# Allication Insights Creation or selection - Default is "false"
#----------------------------------------------------------

data "azurerm_application_insights" "app_insights" {
  count    = var.create_application_insights == false ? 1 : 0
  name                = var.application_insights_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_application_insights" "app_insights" {
  count    = var.create_application_insights ? 1 : 0
  name                = lower(var.application_insights_name)
  location            = local.location
  resource_group_name = local.resource_group_name
  workspace_id        = local.log_analytics_workspace_id
  application_type = var.application_insights_type
  tags     = merge(
  var.common_tags, { 
  Name = format("%s", var.application_insights_name) 
  }
  )
}

#---------------------------------------------------------
# Azure Service Plan Creation or selection - Default is "false"
#----------------------------------------------------------

data "azurerm_service_plan" "this_plan" {
    count = var.create_service_plan == false ? 1 : 0
    name = var.service_plan_name
    resource_group_name = local.resource_group_name
}

resource "azurerm_service_plan" "this_plan" {
  count    = var.create_service_plan ? 1 : 0
  name                = lower(var.service_plan_name)
  location            = local.location
  resource_group_name = local.resource_group_name
  os_type                = var.os_type
  sku_name              = var.service_plan_sku_name
  zone_balancing_enabled = var.enable_zone_redundancy
  tags     = merge(
  var.common_tags, { 
  Name = format("%s", var.service_plan_name) 
  } 
  )
}


#---------------------------------------------------------
# Azure App Service Creation
#----------------------------------------------------------

resource "azurerm_windows_web_app" "this_service" {
  #count = var.number_of_services
  name                = "${var.environment}-${var.solution}-${var.service_name}-app-${var.location_short_ae}-1"
  location            = local.location
  resource_group_name = local.resource_group_name
  service_plan_id = local.service_plan_id
  virtual_network_subnet_id = var.app_service_vnet_integration_subnet_id
  identity {
  type         = "UserAssigned"
  identity_ids = [azurerm_user_assigned_identity.app_user_identity.id]
  }
  https_only                 = true
  
  dynamic "site_config" {
    for_each = [local.site_config]

    content {


      always_on                = lookup(site_config.value, "always_on", null)
      minimum_tls_version      = lookup(site_config.value, "minimum_tls_version", lookup(site_config.value, "min_tls_version", "1.2"))
      vnet_route_all_enabled = var.app_service_vnet_integration_subnet_id != null
      ip_restriction              = local.service_tags
    #   windows_fx_version = lookup(site_config.value, "windows_fx_version", null)
    #   app_command_line         = lookup(site_config.value, "app_command_line", null)
    #   default_documents        = lookup(site_config.value, "default_documents", null)
    #   ftps_state               = lookup(site_config.value, "ftps_state", "Disabled")
    #   health_check_path        = lookup(site_config.value, "health_check_path", null)
    #   http2_enabled            = lookup(site_config.value, "http2_enabled", null)
    #   local_mysql_enabled      = lookup(site_config.value, "local_mysql_enabled", false)
    #   managed_pipeline_mode    = lookup(site_config.value, "managed_pipeline_mode", null)
    #   ip_restriction              = concat(local.subnets, local.cidrs, local.service_tags)
    #   remote_debugging_enabled = lookup(site_config.value, "remote_debugging_enabled", false)
    #   remote_debugging_version = lookup(site_config.value, "remote_debugging_version", null)
    #   websockets_enabled       = lookup(site_config.value, "websockets_enabled", false)

    #   ip_restriction              = concat(local.subnets, local.cidrs, local.service_tags)
    #   scm_type                    = lookup(site_config.value, "scm_type", null)
    #   scm_use_main_ip_restriction = length(var.scm_authorized_ips) > 0 || var.scm_authorized_subnet_ids != null ? false : true
    #   scm_ip_restriction          = concat(local.scm_subnets, local.scm_cidrs, local.scm_service_tags)

      

    dynamic "application_stack" {
        for_each = lookup(site_config.value, "application_stack", null) == null ? [] : ["application_stack"]

        content {
          current_stack          = lookup(local.site_config.application_stack, "current_stack", null)
          dotnet_version         = lookup(local.site_config.application_stack, "dotnet_version", null)
          java_container         = lookup(local.site_config.application_stack, "java_container", null)
          java_container_version = lookup(local.site_config.application_stack, "java_container_version", null)
          java_version           = lookup(local.site_config.application_stack, "java_version", null)
          node_version           = lookup(local.site_config.application_stack, "node_version", null)
          php_version            = lookup(local.site_config.application_stack, "php_version", null)
          python_version         = lookup(local.site_config.application_stack, "python_version", null)
        }
      
    }
 }

}
app_settings = local.app_settings
tags     = merge(
var.common_tags, { 
Name = format("%s", "${var.environment}-${var.solution}-${var.service_name}-app-${var.location_short_ae}-1")
} 
)
}

# resource "azurerm_app_service_virtual_network_swift_connection" "app_service_vnet_integration" {
#   count          = var.app_service_vnet_integration_subnet_id == null ? 0 : 1
#   app_service_id = azurerm_windows_web_app.this_service.id
#   subnet_id      = var.app_service_vnet_integration_subnet_id
# }

#---------------------------------------------------------
# Private Endpoint Creation for App service
#----------------------------------------------------------

resource "azurerm_private_endpoint" "privateendpoint" {
  name                = "${var.environment}-${var.solution}-${var.service_name}-pep-${var.location_short_ae}-1"
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name = "${var.environment}-${var.solution}-${var.service_name}-pepdns-${var.location_short_ae}-1"
    private_dns_zone_ids = [var.webapp_private_dns_zone_id]
  }

  private_service_connection {
    name = "${var.environment}-${var.solution}-${var.service_name}-pep-${var.location_short_ae}-1"
    private_connection_resource_id = azurerm_windows_web_app.this_service.id
    subresource_names = ["sites"]
    is_manual_connection = false
  }
tags     = merge(
var.common_tags, { 
Name = format("%s", "${var.environment}-${var.solution}-${var.service_name}-pep-${var.location_short_ae}-1")
} 
)
}

#---------------------------------------------------------
# User Identity Creation for App service
#----------------------------------------------------------

resource "azurerm_user_assigned_identity" "app_user_identity" {
  location            = local.location
  resource_group_name = local.resource_group_name
  name                = "${var.environment}-${var.solution}-${var.service_name}-app-umi-${var.location_short_ae}-1"

  tags = merge(
    var.common_tags, {
      Name = format("%s", "${var.environment}-${var.solution}-${var.service_name}-app-umi-${var.location_short_ae}-1")
    }
  )
}
