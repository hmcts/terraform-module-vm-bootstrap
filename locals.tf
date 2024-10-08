locals {
  # Custom Script
  bootstrap_vm_script = lower(var.os_type) == "linux" ? "scripts/bootstrap_vm.sh" : "scripts/bootstrap_vm.ps1"

  # Dynatrace Tenant IDs per environment

  dynatrace_tenant_id = var.env == "prod" ? "ebe20728" : "yrk32651"

  dynatrace_server = var.env == "prod" ? "https://dynatrace-activegate-prod.platform.hmcts.net:9999/e/ebe20728/api" : "https://dynatrace-activegate-nonprod.platform.hmcts.net:9999/e/yrk32651/api"

  nessus_server = var.env == "prod" ? "nessus-scanners-prod000005.platform.hmcts.net" : "nessus-scanners-nonprod000005.platform.hmcts.net"

  # Dynatrace OneAgent

  dynatrace_settings = var.dynatrace_hostgroup == null && var.dynatrace_server == null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id == null || var.dynatrace_tenant_id == "" ? local.dynatrace_tenant_id : var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token == null || var.dynatrace_token == "" ? (length(data.azurerm_key_vault_secret.token) > 0 ? data.azurerm_key_vault_secret.token[0].value : "") : var.dynatrace_token}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }" : var.dynatrace_hostgroup != null && var.dynatrace_server == null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"hostGroup\" : \"${var.dynatrace_hostgroup}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\"}" : var.dynatrace_hostgroup == null && var.dynatrace_server != null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"server\" : \"${var.dynatrace_server == null || var.dynatrace_tenant_id == "" ? local.dynatrace_tenant_id : var.dynatrace_tenant_id}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }" : "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"hostGroup\" : \"${var.dynatrace_hostgroup}\" , \"server\" : \"${var.dynatrace_server}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }"
  template_file = base64encode(format("%s\n%s", templatefile("${path.module}/${local.bootstrap_vm_script}",
    {
      UF_INSTALL      = tostring(var.install_splunk_uf),
      UF_USERNAME     = var.splunk_username == null || var.splunk_username == "" ? (length(data.azurerm_key_vault_secret.splunk_username) > 0 ? data.azurerm_key_vault_secret.splunk_username[0].value : "") : var.splunk_username
      UF_PASSWORD     = var.splunk_password == null || var.splunk_password == "" ? (length(data.azurerm_key_vault_secret.splunk_password) > 0 ? data.azurerm_key_vault_secret.splunk_password[0].value : "") : var.splunk_password
      UF_PASS4SYMMKEY = var.splunk_pass4symmkey == null || var.splunk_pass4symmkey == "" ? (length(data.azurerm_key_vault_secret.splunk_pass4symmkey) > 0 ? data.azurerm_key_vault_secret.splunk_pass4symmkey[0].value : "") : var.splunk_pass4symmkey
      UF_GROUP        = var.splunk_group
      NESSUS_INSTALL  = tostring(var.install_nessus_agent)
      NESSUS_SERVER   = var.nessus_server == null || var.nessus_server == "" ? local.nessus_server : var.nessus_server
      NESSUS_KEY      = var.nessus_key == null || var.nessus_key == "" ? (length(data.azurerm_key_vault_secret.nessus_agent_key) > 0 ? data.azurerm_key_vault_secret.nessus_agent_key[0].value : "") : var.nessus_key
      NESSUS_GROUPS   = var.nessus_groups == null || var.nessus_groups == "" ? "Platform-Operation-Bastions" : var.nessus_groups
  }), var.additional_script_path == null ? "" : file("${var.additional_script_path}")))

  additional_template_file = var.additional_script_uri != null ? format("%s%s%s", "[ ", "\"${var.additional_script_uri}\"", " ]") : "\"\""

  cnp_vault_rg = var.cnp_vault_rg == null ? var.env != "prod" ? "cnp-core-infra" : "core-infra-${var.env}" : var.cnp_vault_rg

  xdr_tags_list = var.xdr_tags != null ? join(",", [var.xdr_tags, "hmcts,server"]) : "hmcts,server"

  vm_name   = var.virtual_machine_id != null ? regex("virtualMachines/([^/]+)", var.virtual_machine_id)[0] : null
  vmss_name = var.virtual_machine_scale_set_id != null ? regex("virtualMachineScaleSets/([^/]+)", var.virtual_machine_scale_set_id)[0] : null

}
