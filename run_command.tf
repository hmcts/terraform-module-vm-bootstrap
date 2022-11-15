resource "azurerm_virtual_machine_scale_set_extension" "azure_vmss_run_command" {
  count = var.run_command == true && var.virtual_machine_type == "vmss" ? 1 : 0

  name                         = "${lower(var.os_type)}-run-command"
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  publisher                    = "Microsoft.CPlat.Core"
  type                         = lower(var.os_type) == "linux" ? "RunCommandLinux" : lower(var.os_type) == "windows" ? "RunCommandWindows" : null
  type_handler_version         = lower(var.os_type) == "linux" ? var.run_command_type_handler_version : var.run_command_type_handler_version_windows
  auto_upgrade_minor_version   = true
  settings = jsonencode({
    script = compact(tolist([file("${path.module}/${var.rc_script_file}")]))
  })
}

resource "azurerm_virtual_machine_extension" "azure_vm_run_command" {
  count = var.run_command == true && var.virtual_machine_type == "vm" ? 1 : 0

  name                       = "${lower(var.os_type)}-run-command"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.CPlat.Core"
  type                       = lower(var.os_type) == "linux" ? "RunCommandLinux" : lower(var.os_type) == "windows" ? "RunCommandWindows" : null
  type_handler_version       = lower(var.os_type) == "linux" ? var.run_command_type_handler_version : var.run_command_type_handler_version_windows
  auto_upgrade_minor_version = true

  settings = jsonencode({
    script = lower(var.os_type) == "windows" ? compact(tolist([file("${path.module}/${var.rc_script_file}")])) : null
  })
  protected_settings =<<PROTECTED_SETTINGS
    {
      %{if var.os_type == "Linux"}
      "script": "${file("${path.module}/${var.rc_script_file}")}"
      %{else}
      "script": ""
      %{endif}
    }
    PROTECTED_SETTINGS

  tags = var.common_tags
  depends_on                     = [azurerm_virtual_machine_extension.custom_script]
}
