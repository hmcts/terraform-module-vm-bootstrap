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

  depends_on = [azurerm_virtual_machine_scale_set_extension.custom_script]
}

resource "azurerm_virtual_machine_extension" "azure_vm_run_command" {
  count = var.run_command == true && var.virtual_machine_type == "vm" ? 1 : 0

  name                       = "${lower(var.os_type)}-run-command"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.CPlat.Core"
  type                       = lower(var.os_type) == "linux" ? "RunCommandLinux" : lower(var.os_type) == "windows" ? "RunCommandWindows" : null
  type_handler_version       = lower(var.os_type) == "linux" ? var.run_command_type_handler_version : var.run_command_type_handler_version_windows
  auto_upgrade_minor_version = true

  protected_settings = lower(var.os_type) == "linux" ? jsonencode({ commandToExecute = tostring(templatefile("${path.module}/scripts/linux_run_script.sh", {
    STORAGE_ACCOUNT_KEY = var.run_command_sa_key
    RUN_XDR_COLLECTOR   = var.run_xdr_collector ? "true" : "false"
    RUN_XDR_AGENT       = var.run_xdr_agent ? "true" : "false"
    ENV                 = var.xdr_env == "prod" ? var.xdr_env : "nonprod"
    XDR_TAGS            = local.xdr_tags_list
    })) }) : jsonencode({ script = compact(tolist([templatefile("${path.module}/scripts/windows_run_script.ps1", {
      STORAGE_ACCOUNT_KEY = var.run_command_sa_key
      RUN_CIS             = var.rc_script_file == "scripts/windows_cis.ps1" || var.run_cis ? "true" : "false"
      RUN_XDR_COLLECTOR   = var.run_xdr_collector ? "true" : "false"
      RUN_XDR_AGENT       = var.run_xdr_agent ? "true" : "false"
      ENV                 = var.xdr_env == "prod" ? var.xdr_env : "nonprod"
      XDR_TAGS            = local.xdr_tags_list
    })]))
  })


  tags       = var.common_tags
  depends_on = [azurerm_virtual_machine_extension.custom_script]
}

output "XDR_TAGS" {
  value = local.xdr_tags_list
}
