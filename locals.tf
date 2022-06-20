locals {
  # Custom Script
  bootstrap_vm_script = lower(var.os_type) == "linux" ? "scripts/bootstrap_vm.sh" : "scripts/bootstrap_vm.ps1"

  # Dynatrace OneAgent
  dynatrace_settings = var.dynatrace_hostgroup == null && var.dynatrace_server == null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }" : var.dynatrace_hostgroup != null && var.dynatrace_server == null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"hostGroup\" : \"${var.dynatrace_hostgroup}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\"}" : var.dynatrace_hostgroup == null && var.dynatrace_server != null ? "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"server\" : \"${var.dynatrace_server}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }" : "{ \"tenantId\" : \"${var.dynatrace_tenant_id}\" , \"token\" : \"${var.dynatrace_token}\" , \"hostGroup\" : \"${var.dynatrace_hostgroup}\" , \"server\" : \"${var.dynatrace_server}\" , \"installerArguments\" : \"--set-network-zone=${var.dynatrace_network_zone}\" }"

}

