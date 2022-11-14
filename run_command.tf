resource "azurerm_virtual_machine_scale_set_extension" "azure_vmss_run_command" {
  count = var.run_command == true && var.virtual_machine_type == "vmss" ? 1 : 0

  name                         = "${lower(var.os_type)}-run-command"
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  publisher                    = "Microsoft.CPlat.Core"
  type                         = lower(var.os_type) == "linux" ? "RunCommandLinux" : lower(var.os_type) == "windows" ? "RunCommandWindows" : null
  type_handler_version         = lower(var.os_type) == "linux" ? var.run_command_type_handler_version : var.run_command_type_handler_version_windows
  auto_upgrade_minor_version   = false
  settings                     = lower(var.os_type) == "linux" ? "${jsonencode(local.run_settings_linux)}" : lower(var.os_type) == "windows" ? "${jsonencode(local.run_settings_windows)}" : null

  #   settings                     = var.run_command_settings
  #   protected_settings           = lower(var.os_type) == "linux" ? "${jsonencode(local.run_settings_linux)}" : lower(var.os_type) == "windows" ? "${jsonencode(local.run_settings_windows)}" : null
}

resource "azurerm_virtual_machine_extension" "azure_vm_run_command" {
  count = var.run_command == true && var.virtual_machine_type == "vm" ? 1 : 0

  name                       = "${lower(var.os_type)}-run-command"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.CPlat.Core"
  type                       = lower(var.os_type) == "linux" ? "RunCommandLinux" : lower(var.os_type) == "windows" ? "RunCommandWindows" : null
  type_handler_version       = lower(var.os_type) == "linux" ? var.run_command_type_handler_version : var.run_command_type_handler_version_windows
  auto_upgrade_minor_version = false
  settings                   = lower(var.os_type) == "linux" ? "${jsonencode(local.run_settings_linux)}" : lower(var.os_type) == "windows" ? "${jsonencode(local.run_settings_windows)}" : null
  #   settings                   = var.run_command_settings
  #   protected_settings         = lower(var.os_type) == "linux" ? "${jsonencode(local.run_settings_linux)}" : lower(var.os_type) == "windows" ? "${jsonencode(local.run_settings_windows)}" : null


  tags = var.common_tags
}
