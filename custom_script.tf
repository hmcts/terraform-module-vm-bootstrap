# Custom Script
resource "azurerm_virtual_machine_scale_set_extension" "custom_script" {
  count = (var.install_splunk_uf == true || var.install_nessus_agent == true || var.additional_script_path != null) && var.virtual_machine_type == "vmss" ? 1 : 0

  depends_on = [azurerm_virtual_machine_scale_set_extension.azure_monitor]

  name                         = var.custom_script_extension_name
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  publisher                    = lower(var.os_type) == "linux" ? "Microsoft.Azure.Extensions" : lower(var.os_type) == "windows" ? "Microsoft.Compute" : null
  type                         = lower(var.os_type) == "linux" ? "CustomScript" : lower(var.os_type) == "windows" ? "CustomScriptExtension" : null
  type_handler_version         = lower(var.os_type) == "linux" ? var.custom_script_type_handler_version : var.custom_script_type_handler_version_windows
  auto_upgrade_minor_version   = false
  protected_settings           = <<PROTECTED_SETTINGS
    {
      %{if var.os_type == "Linux"}
      "script": "${local.template_file}"
      %{else}
      "fileUris": ${local.additional_template_file},
      "commandToExecute": "${var.additional_script_uri == null ? "" : "powershell -ExecutionPolicy Unrestricted -File ${var.additional_script_name} &&"} powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${local.template_file}')) | Out-File -filepath bootstrap_vm.ps1\" && powershell -ExecutionPolicy Unrestricted -File bootstrap_vm.ps1"
      %{endif}
    }
    PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  count = (var.install_splunk_uf == true || var.install_nessus_agent == true || var.additional_script_path != null) && var.virtual_machine_type == "vm" ? 1 : 0

  depends_on = [azurerm_virtual_machine_extension.azure_monitor]

  name                       = var.custom_script_extension_name
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = lower(var.os_type) == "linux" ? "Microsoft.Azure.Extensions" : lower(var.os_type) == "windows" ? "Microsoft.Compute" : null
  type                       = lower(var.os_type) == "linux" ? "CustomScript" : lower(var.os_type) == "windows" ? "CustomScriptExtension" : null
  type_handler_version       = lower(var.os_type) == "linux" ? var.custom_script_type_handler_version : var.custom_script_type_handler_version_windows
  auto_upgrade_minor_version = false
  protected_settings         = <<PROTECTED_SETTINGS
    {
      %{if var.os_type == "Linux"}
      "script": "${local.template_file}"
      %{else}
      "fileUris": ${local.additional_template_file},
      "commandToExecute": "${var.additional_script_uri == null ? "" : "powershell -ExecutionPolicy Unrestricted -File ${var.additional_script_name} &&"} powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${local.template_file}')) | Out-File -filepath bootstrap_vm.ps1\" && powershell -ExecutionPolicy Unrestricted -File bootstrap_vm.ps1",
      "managedIdentity" : "${try({ "clientId" : var.additional_script_mi_id }, {})}"
      %{endif}
    }
    PROTECTED_SETTINGS

  tags = var.common_tags
}
