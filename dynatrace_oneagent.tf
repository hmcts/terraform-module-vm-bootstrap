resource "azurerm_virtual_machine_scale_set_extension" "dynatrace_oneagent" {
  count = var.install_dynatrace_oneagent == true && var.virtual_machine_type == "vmss" ? 1 : 0

  depends_on = [azurerm_virtual_machine_scale_set_extension.azure_monitor]

  name                         = "Dynatrace"
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  publisher                    = "dynatrace.ruxit"
  type                         = lower(var.os_type) == "linux" ? "oneAgentLinux" : lower(var.os_type) == "windows" ? "oneAgentWindows" : null
  type_handler_version         = var.dynatrace_type_handler_version
  auto_upgrade_minor_version   = var.dynatrace_auto_upgrade_minor_version
  settings                     = local.dynatrace_settings
}

resource "azurerm_virtual_machine_extension" "dynatrace_oneagent" {
  count = var.install_dynatrace_oneagent == true && var.virtual_machine_type == "vm" ? 1 : 0

  depends_on = [azurerm_virtual_machine_scale_set_extension.azure_monitor]

  name                       = "Dynatrace"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "dynatrace.ruxit"
  type                       = lower(var.os_type) == "linux" ? "oneAgentLinux" : lower(var.os_type) == "windows" ? "oneAgentWindows" : null
  type_handler_version       = var.dynatrace_type_handler_version
  auto_upgrade_minor_version = var.dynatrace_auto_upgrade_minor_version
  settings                   = local.dynatrace_settings

  tags = var.common_tags
}
