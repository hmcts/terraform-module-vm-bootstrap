resource "azurerm_virtual_machine_extension" "vm_aad" {
  count                      = var.windows_aad_login == true && var.os_type == "Windows" ? 1 : 0
  name                       = "AADLoginForWindows"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = var.common_tags
}
