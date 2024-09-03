resource "azurerm_virtual_machine_scale_set_extension" "azure_monitor" {
  count = var.install_azure_monitor == true && var.virtual_machine_type == "vmss" ? 1 : 0

  name                         = lower(var.os_type) == "linux" ? "AMALinux" : lower(var.os_type) == "windows" ? "AMAWindows" : null
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  publisher                    = "Microsoft.Azure.Monitor"
  type                         = lower(var.os_type) == "linux" ? "AzureMonitorLinuxAgent" : lower(var.os_type) == "windows" ? "AzureMonitorWindowsAgent" : null
  type_handler_version         = var.azure_monitor_type_handler_version
  auto_upgrade_minor_version   = var.azure_monitor_auto_upgrade_minor_version
  settings                     = var.azure_monitor_settings
  protected_settings           = var.azure_monitor_protected_settings
}

resource "azurerm_virtual_machine_extension" "azure_monitor" {
  count = var.install_azure_monitor == true && var.virtual_machine_type == "vm" ? 1 : 0

  name                       = lower(var.os_type) == "linux" ? "AMALinux" : lower(var.os_type) == "windows" ? "AMAWindows" : null
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = lower(var.os_type) == "linux" ? "AzureMonitorLinuxAgent" : lower(var.os_type) == "windows" ? "AzureMonitorWindowsAgent" : null
  type_handler_version       = var.azure_monitor_type_handler_version
  auto_upgrade_minor_version = var.azure_monitor_auto_upgrade_minor_version
  settings                   = var.azure_monitor_settings
  protected_settings         = var.azure_monitor_protected_settings

  tags = var.common_tags
}

data "azurerm_resource_group" "log_analytics_rg" {
  provider = azurerm.loganalytics
  name     = "oms-automation"
}

data "azurerm_log_analytics_workspace" "workspace" {
  provider            = azurerm.loganalytics
  name                = var.log_analytics_workspace_names[var.env]
  resource_group_name = data.azurerm_resource_group.log_analytics_rg.name
}

resource "azurerm_monitor_data_collection_rule" "windows_data_collection_rule" {
  provider            = azurerm.loganalytics
  name                = "ama-windows-vm-logs"
  resource_group_name = data.azurerm_log_analytics_workspace.workspace.resource_group_name
  location            = var.location
  kind                = "Windows"
  description         = "A data collection rule for collecting Windows event logs and sending them to the appropriate log analytics workspace."

  destinations {
    log_analytics {
      workspace_resource_id = data.azurerm_log_analytics_workspace.workspace.id
      name                  = local.log_analytics_workspace
    }
  }

  data_flow {
    streams      = ["Microsoft-WindowsEvent"]
    destinations = [local.log_analytics_workspace]
  }

  data_sources {
    windows_event_log {
      streams        = ["Microsoft-WindowsEvent"]
      x_path_queries = ["Application!*[System[(Level = 1 or Level = 2 or Level = 3)]]", "System!*[System[(Level = 1 or Level = 2 or Level = 3)]]"]
      name           = "ms-windows-event-log"
    }

    windows_event_log {
      streams        = ["Microsoft-Event"]
      x_path_queries = ["Application!*[System[(Level = 1 or Level = 2 or Level = 3)]]", "System!*[System[(Level = 1 or Level = 2 or Level = 3)]]"]
      name           = "ms-event-log"
    }

    windows_event_log {
      streams        = ["Microsoft-SecurityEvent"]
      x_path_queries = ["Application!*[System[(Level = 1 or Level = 2 or Level = 3)]]", "System!*[System[(Level = 1 or Level = 2 or Level = 3)]]"]
      name           = "ms-security-event-log"
    }
  }
}

resource "azurerm_monitor_data_collection_rule" "linux_data_collection_rule" {
  provider            = azurerm.loganalytics
  name                = "ama-linux-vm-logs"
  resource_group_name = data.azurerm_log_analytics_workspace.workspace.resource_group_name
  location            = var.location
  kind                = "Linux"
  description         = "A data collection rule for collecting Linux syslog and performance counters and sending them to the appropriate log analytics workspace."

  destinations {
    log_analytics {
      workspace_resource_id = data.azurerm_log_analytics_workspace.workspace.id
      name                  = local.log_analytics_workspace
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = [local.log_analytics_workspace]
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = [local.log_analytics_workspace]
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 300
      counter_specifiers            = ["% Used Inodes", "% Used Space", "Disk Reads/sec", "Disk Transfers/sec", "Disk Writes/sec", "Free Megabytes"]
      name                          = "ms-performance"
    }

    syslog {
      facility_names = ["auth", "cron", "daemon", "local0", "local1", "local2", "local3", "local4", "local5", "local6", "local7", "user"]
      log_levels     = ["Emergency", "Alert", "Critical", "Error"]
      streams        = ["Microsoft-Syslog"]
      name           = "ms-syslog-error"
    }

    syslog {
      facility_names = ["syslog"]
      log_levels     = ["Emergency", "Alert", "Critical", "Error", "Warning", "Notice", "Info"]
      streams        = ["Microsoft-Syslog"]
      name           = "ms-syslog-info"
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "linux_vm_dcra" {
  count = var.install_azure_monitor == true && lower(var.os_type) == "linux" && var.virtual_machine_type == "vm" ? 1 : 0

  name                    = "vm-${var.virtual_machine_id}-dcra"
  target_resource_id      = var.virtual_machine_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.linux_data_collection_rule.id
  description             = "Association between a linux VM and the appropriate data collection rule."
}

resource "azurerm_monitor_data_collection_rule_association" "linux_vmss_dcra" {
  count = var.install_azure_monitor == true && lower(var.os_type) == "linux" && var.virtual_machine_type == "vmss" ? 1 : 0

  name                    = "vmss-${var.virtual_machine_scale_set_id}-dcra"
  target_resource_id      = var.virtual_machine_scale_set_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.linux_data_collection_rule.id
  description             = "Association between a linux VMSS and the appropriate data collection rule."
}

resource "azurerm_monitor_data_collection_rule_association" "windows_vm_dcra" {
  count = var.install_azure_monitor == true && lower(var.os_type) == "windows" && var.virtual_machine_type == "vm" ? 1 : 0

  name                    = "vm-${var.virtual_machine_id}-dcra"
  target_resource_id      = var.virtual_machine_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.windows_data_collection_rule.id
  description             = "Association between a windows VM and the appropriate data collection rule."
}

resource "azurerm_monitor_data_collection_rule_association" "windows_vmss_dcra" {
  count = var.install_azure_monitor == true && lower(var.os_type) == "windows" && var.virtual_machine_type == "vmss" ? 1 : 0

  name                    = "vmss-${var.virtual_machine_scale_set_id}-dcra"
  target_resource_id      = var.virtual_machine_scale_set_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.windows_data_collection_rule.id
  description             = "Association between a windows VMSS and the appropriate data collection rule."
}
