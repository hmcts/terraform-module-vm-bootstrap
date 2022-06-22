locals {
  # Custom Script
  bootstrap_vm_script = lower(var.os_type) == "linux" ? "scripts/bootstrap_vm.sh" : "scripts/bootstrap_vm.ps1"

  # Dynatrace OneAgent
  dynatrace_settings = var.dynatrace_hostgroup == null && var.dynatrace_server == null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }" : var.dynatrace_hostgroup != null && var.dynatrace_server == null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"hostGroup\" : \"${var.dynatrace_hostgroup}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\"}" : var.dynatrace_hostgroup == null && var.dynatrace_server != null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"server\" : \"${var.dynatrace_server}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }" : "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"hostGroup\" : \"${var.dynatrace_hostgroup}\" , \"server\" : \"${var.dynatrace_server}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }"

  template_file = base64encode(format("%s\n%s",templatefile("${path.module}/${local.bootstrap_vm_script}" ,{
    UF_INSTALL      = tostring(var.install_splunk_uf),
    UF_USERNAME     = var.splunk_username,
    UF_PASSWORD     = var.splunk_password,
    UF_PASS4SYMMKEY = var.splunk_pass4symmkey,
    UF_GROUP        = var.splunk_group,
    NESSUS_INSTALL  = var.install_nessus_agent,
    NESSUS_SERVER   = var.nessus_server,
    NESSUS_KEY      = var.nessus_key,
    NESSUS_GROUPS   = var.nessus_groups
  }), var.additional_script_path == null ? "" : templatefile("${var.additional_script_path}", {})))

  additional_template_file = var.additional_script_uri != null ? format("%s%s%s", "[ ", "\"${var.additional_script_uri}\"", " ]") : "\"\""
}

