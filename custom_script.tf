# Custom Script
resource "azurerm_virtual_machine_scale_set_extension" "custom_script" {
  count = (var.install_splunk_uf == true || var.additional_script_path != null) && var.virtual_machine_type == "vmss" ? 1 : 0

  name                         = var.custom_script_extension_name
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  publisher                    = lower(var.os_type) == "linux" ? "Microsoft.Azure.Extensions" : lower(var.os_type) == "windows" ? "Microsoft.Compute" : null
  type                         = lower(var.os_type) == "linux" ? "CustomScript" : lower(var.os_type) == "windows" ? "CustomScriptExtension" : null
  type_handler_version         = lower(var.os_type) == "linux" ? var.custom_script_type_handler_version : var.custom_script_type_handler_version_windows
  auto_upgrade_minor_version   = false
  protected_settings = <<PROTECTED_SETTINGS
    {
      "script": "${base64encode(format("%s%s", templatefile("${path.module}/${local.bootstrap_vm_script}", {
  UF_USERNAME     = "${var.splunk_username}",
  UF_PASSWORD     = "${var.splunk_password}",
  UF_PASS4SYMMKEY = "${var.splunk_pass4symmkey}",
  UF_GROUP        = "${var.splunk_group}"
}), var.additional_script_path == null ? "" : templatefile("${var.additional_script_path}", {})))}"
    }
    PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  count = (var.install_splunk_uf == true || var.additional_script_path != null) && var.virtual_machine_type == "vm" ? 1 : 0

  name                       = var.custom_script_extension_name
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = lower(var.os_type) == "linux" ? "Microsoft.Azure.Extensions" : lower(var.os_type) == "windows" ? "Microsoft.Compute" : null
  type                       = lower(var.os_type) == "linux" ? "CustomScript" : lower(var.os_type) == "windows" ? "CustomScriptExtension" : null
  type_handler_version       = lower(var.os_type) == "linux" ? var.custom_script_type_handler_version : var.custom_script_type_handler_version_windows
  auto_upgrade_minor_version = false
  protected_settings = <<PROTECTED_SETTINGS
    {
      "script": "${base64encode(format("%s\n%s", templatefile("${path.module}/${local.bootstrap_vm_script}", {
  UF_INSTALL      = "${tostring(var.install_splunk_uf)}",
  UF_USERNAME     = "${var.splunk_username}",
  UF_PASSWORD     = "${var.splunk_password}",
  UF_PASS4SYMMKEY = "${var.splunk_pass4symmkey}",
  UF_GROUP        = "${var.splunk_group}"
}), var.additional_script_path == null ? "" : templatefile("${var.additional_script_path}", {})))}"
    }
    PROTECTED_SETTINGS
}
