resource "azurerm_virtual_machine_scale_set_extension" "dynatrace_oneagent" {
  count = var.install_dynatrace_oneagent == true && var.virtual_machine_type == "vmss" ? 1 : 0

  depends_on = [ azurerm_virtual_machine_scale_set_extension.custom_script ]

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

  depends_on = [ azurerm_virtual_machine_extension.custom_script ]

  name                       = "Dynatrace"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "dynatrace.ruxit"
  type                       = lower(var.os_type) == "linux" ? "oneAgentLinux" : lower(var.os_type) == "windows" ? "oneAgentWindows" : null
  type_handler_version       = var.dynatrace_type_handler_version
  auto_upgrade_minor_version = var.dynatrace_auto_upgrade_minor_version
  settings                   = local.dynatrace_settings

  tags = var.common_tags
}

  # Splunk UF
  splunk_username     = data.azurerm_key_vault_secret.splunk_username.value
  splunk_password     = data.azurerm_key_vault_secret.splunk_password.value
  splunk_pass4symmkey = data.azurerm_key_vault_secret.splunk_pass4symmkey.value

  # Tenable Nessus
  nessus_server  = var.nessus_server
  nessus_key     = data.azurerm_key_vault_secret.nessus_agent_key.value
  nessus_groups  = "Platform-Operation-Bastions"

  # Dynatrace OneAgent
  dynatrace_hostgroup        = "Platform_Operation_Jumpboxes"
  dynatrace_tenant_id        = var.dynatrace_tenant_id
  dynatrace_token            = data.azurerm_key_vault_secret.token.value
  dynatrace_server           = var.dynatrace_server
