resource "azurerm_virtual_machine_scale_set_extension" "endpoint_protection" {
  count = var.install_endpoint_protection == true && var.virtual_machine_type == "vmss" ? 1 : 0

  name                         = "AntiMalware Endpoint Protection"
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  publisher                    = "Microsoft.Azure.Security"
  type                         = "IaaSAntimalware"
  type_handler_version         = var.endpoint_protection_handler_version
  auto_upgrade_minor_version   = var.endpoint_protection_upgrade_minor_version
  settings                     = local.endpoint_protection_settings
}

resource "azurerm_virtual_machine_extension" "endpoint_protection" {
  count = var.install_endpoint_protection == true && var.virtual_machine_type == "vm" ? 1 : 0

  name                         = "AntiMalware Endpoint Protection"
  virtual_machine_id           = var.virtual_machine_id
  publisher                    = "Microsoft.Azure.Security"
  type                         = "IaaSAntimalware"
  type_handler_version         = var.endpoint_protection_handler_version
  auto_upgrade_minor_version   = var.endpoint_protection_upgrade_minor_version
  settings                     = local.endpoint_protection_settings

  tags = var.common_tags
}
