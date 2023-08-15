locals {
  # Custom Script
  bootstrap_vm_script = lower(var.os_type) == "linux" ? "scripts/bootstrap_vm.sh" : "scripts/bootstrap_vm.ps1"

  # Dynatrace Tenant IDs per environment

  dynatrace_tenant_id = var.env == "prod" ? "ebe20728" : "yrk32651"

  dynatrace_server = var.env == "prod" ? "https://10.10.70.30:9999/e/ebe20728/api" : "https://yrk32651.live.dynatrace.com/api\n"

  nessus_server = var.nessus_server == "prod" ? "nessus-scanners-prod000005.platform.hmcts.net" : "https://10.10.70.8:9999/e/yrk32651/api\n"

  # Dynatrace OneAgent

  dynatrace_settings = var.dynatrace_hostgroup == null && var.dynatrace_server == null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id == null || var.dynatrace_tenant_id == "" ? local.dynatrace_tenant_id : var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token == null || var.dynatrace_token == "" ? data.azurerm_key_vault_secret.token[0].value : var.dynatrace_token}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }" : var.dynatrace_hostgroup != null && var.dynatrace_server == null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"hostGroup\" : \"${var.dynatrace_hostgroup}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\"}" : var.dynatrace_hostgroup == null && var.dynatrace_server != null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"server\" : \"${var.dynatrace_server == null || var.dynatrace_tenant_id == "" ? local.dynatrace_tenant_id : var.dynatrace_tenant_id}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }" : "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"hostGroup\" : \"${var.dynatrace_hostgroup}\" , \"server\" : \"${var.dynatrace_server}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }"
  template_file = base64encode(format("%s\n%s", templatefile("${path.module}/${local.bootstrap_vm_script}",
  {
    UF_INSTALL      = tostring(var.install_splunk_uf),
    UF_USERNAME     = var.splunk_username == null || var.splunk_username == "" ? data.azurerm_key_vault_secret.splunk_username.value : var.splunk_username
    UF_PASSWORD     = var.splunk_password == null || var.splunk_password == "" ? data.azurerm_key_vault_secret.splunk_password.value : var.splunk_password
    UF_PASS4SYMMKEY = var.splunk_pass4symmkey == null || var.splunk_pass4symmkey == "" ? data.azurerm_key_vault_secret.splunk_pass4symmkey.value : var.splunk_pass4symmkey
    UF_GROUP        = var.splunk_group
    NESSUS_INSTALL  = var.install_nessus_agent == null || var.install_nessus_agent == "" ? data.azurerm_key_vault_secret.nessus_agent_key.value : var.install_nessus_agent
    NESSUS_SERVER   = var.nessus_server == null || var.nessus_server == "" ? local.dynatrace_server : var.nessus_server
    NESSUS_KEY      = var.nessus_key == null || var.nessus_key == "" ? data.azurerm_key_vault_secret.nessus_agent_key.value : var.nessus_key
    NESSUS_GROUPS   = var.nessus_group
  }), var.additional_script_path == null ? "" : file("${var.additional_script_path}")))

  additional_template_file = var.additional_script_uri != null ? format("%s%s%s", "[ ", "\"${var.additional_script_uri}\"", " ]") : "\"\""
}

