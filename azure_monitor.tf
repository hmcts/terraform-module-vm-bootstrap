resource "azurerm_virtual_machine_scale_set_extension" "azure_monitor" {
  count = var.install_azure_monitor == true && var.virtual_machine_type == "vmss" ? 1 : 0

  name                         = lower(var.os_type) == "linux" ? "AMALinux" : lower(var.os_type) == "windows" ? "AMAWindows" : null
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  publisher                    = "Microsoft.Azure.Monitor"
  type                         = lower(var.os_type) == "linux" ? "AzureMonitorLinuxAgent" : lower(var.os_type) == "windows" ? "AzureMonitorWindowsAgent" : null
  type_handler_version         = var.azure_monitor_type_handler_version
  auto_upgrade_minor_version   = var.azure_monitor_auto_upgrade_minor_version
  automatic_upgrade_enabled    = var.azure_monitor_automatic_upgrade_enabled
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
  automatic_upgrade_enabled  = var.azure_monitor_automatic_upgrade_enabled
  settings                   = var.azure_monitor_settings
  protected_settings         = var.azure_monitor_protected_settings

  tags = var.common_tags
}
