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

data "azurerm_resource_group" "la_rg" {
  provider = azurerm.dcr
  name     = "oms-automation"
}

data "azurerm_monitor_data_collection_rule" "linux_data_collection_rule" {
  provider            = azurerm.dcr
  name                = "ama-linux-vm-logs"
  resource_group_name = data.azurerm_resource_group.la_rg.name
}

data "azurerm_monitor_data_collection_rule" "windows_data_collection_rule" {
  provider            = azurerm.dcr
  name                = "ama-windows-vm-logs"
  resource_group_name = data.azurerm_resource_group.la_rg.name
}


resource "azurerm_monitor_data_collection_rule_association" "linux_vm_dcra" {
  count = var.install_azure_monitor == true && lower(var.os_type) == "linux" && var.virtual_machine_type == "vm" && contains(["sbox", "sandbox"], var.env) ? 1 : 0

  name                    = "vm-${local.vm_name}-dcra"
  target_resource_id      = var.virtual_machine_id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.linux_data_collection_rule.id
  description             = "Association between a linux VM and the appropriate data collection rule."
}

resource "azurerm_monitor_data_collection_rule_association" "linux_vmss_dcra" {
  count = var.install_azure_monitor == true && lower(var.os_type) == "linux" && var.virtual_machine_type == "vmss" ? 1 : 0

  name                    = "vmss-${local.vmss_name}-dcra"
  target_resource_id      = var.virtual_machine_scale_set_id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.linux_data_collection_rule.id
  description             = "Association between a linux VMSS and the appropriate data collection rule."
}

resource "azurerm_monitor_data_collection_rule_association" "windows_vm_dcra" {
  count = var.install_azure_monitor == true && lower(var.os_type) == "windows" && var.virtual_machine_type == "vm" ? 1 : 0

  name                    = "vm-${local.vm_name}-dcra"
  target_resource_id      = var.virtual_machine_id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.windows_data_collection_rule.id
  description             = "Association between a windows VM and the appropriate data collection rule."
}

resource "azurerm_monitor_data_collection_rule_association" "windows_vmss_dcra" {
  count = var.install_azure_monitor == true && lower(var.os_type) == "windows" && var.virtual_machine_type == "vmss" ? 1 : 0

  name                    = "vmss-${local.vmss_name}-dcra"
  target_resource_id      = var.virtual_machine_scale_set_id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.windows_data_collection_rule.id
  description             = "Association between a windows VMSS and the appropriate data collection rule."
}
