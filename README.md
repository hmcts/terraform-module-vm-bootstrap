# terraform-module-vm-bootstrap

A Terraform module for bootstrapping Linux or Windows Virtual Machines or Virtual Machine Scale Sets via supported agents and/custom scripts.

Supported Agents:

- Azure Monitor
- Dynatrace OneAgent
- Splunk Universal Forwarder
- Tenable Nessus Agent
- Run Command
- Microsoft Antimalware

## Outdated Links

If the tenable install is failing please check that the download link has not expired as the link changes often. https://www.tenable.com/downloads

## Requirements

A virtual machine or virtual machine scale set.

<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_azurerm.cnp"></a> [azurerm.cnp](#provider\_azurerm.cnp) | n/a |
| <a name="provider_azurerm.dcr"></a> [azurerm.dcr](#provider\_azurerm.dcr) | n/a |
| <a name="provider_azurerm.soc"></a> [azurerm.soc](#provider\_azurerm.soc) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_data_collection_rule_association.linux_vm_dcra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_monitor_data_collection_rule_association.linux_vmss_dcra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_monitor_data_collection_rule_association.windows_vm_dcra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_monitor_data_collection_rule_association.windows_vmss_dcra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_virtual_machine_extension.azure_monitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.azure_vm_run_command](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.custom_script](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.dynatrace_oneagent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.endpoint_protection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.azure_monitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.azure_vmss_run_command](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.custom_script](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.dynatrace_oneagent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.endpoint_protection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_key_vault.cnp_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault.soc_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.nessus_agent_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.splunk_pass4symmkey](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.splunk_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.splunk_username](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.token](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_monitor_data_collection_rule.linux_data_collection_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_data_collection_rule) | data source |
| [azurerm_monitor_data_collection_rule.windows_data_collection_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_data_collection_rule) | data source |
| [azurerm_resource_group.la_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_script_mi_id"></a> [additional\_script\_mi\_id](#input\_additional\_script\_mi\_id) | This variable will be used to pass Managed Identity ID when the additional script has been used | `any` | `null` | no |
| <a name="input_additional_script_name"></a> [additional\_script\_name](#input\_additional\_script\_name) | Additional script name when using script additional\_script\_uri. | `any` | `null` | no |
| <a name="input_additional_script_path"></a> [additional\_script\_path](#input\_additional\_script\_path) | Path to additional script. | `any` | `null` | no |
| <a name="input_additional_script_uri"></a> [additional\_script\_uri](#input\_additional\_script\_uri) | Uri download link to additional script | `any` | `null` | no |
| <a name="input_antimalwareenabled"></a> [antimalwareenabled](#input\_antimalwareenabled) | Enable AntiMalware Protection | `string` | `true` | no |
| <a name="input_azure_monitor_auto_upgrade_minor_version"></a> [azure\_monitor\_auto\_upgrade\_minor\_version](#input\_azure\_monitor\_auto\_upgrade\_minor\_version) | Specifies if the platform deploys the latest minor version Azure Monitor update to the type\_handler\_version specified. | `bool` | `true` | no |
| <a name="input_azure_monitor_protected_settings"></a> [azure\_monitor\_protected\_settings](#input\_azure\_monitor\_protected\_settings) | The protected\_settings passed to the Azure Monitor extension, like settings, these are specified as a JSON object in a string. | `string` | `null` | no |
| <a name="input_azure_monitor_settings"></a> [azure\_monitor\_settings](#input\_azure\_monitor\_settings) | The settings passed to the Azure Monitor extension, these are specified as a JSON object in a string. | `string` | `null` | no |
| <a name="input_azure_monitor_type_handler_version"></a> [azure\_monitor\_type\_handler\_version](#input\_azure\_monitor\_type\_handler\_version) | Version of Azure Monitor - To find: az vm extension image list --location uksouth -p Microsoft.Azure.Monitor -o table | `string` | `"1.9"` | no |
| <a name="input_cnp_vault_rg"></a> [cnp\_vault\_rg](#input\_cnp\_vault\_rg) | The name of the resource group where the CNP Key Vault is located. | `string` | `null` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common Tags | `map(string)` | `null` | no |
| <a name="input_custom_script_extension_name"></a> [custom\_script\_extension\_name](#input\_custom\_script\_extension\_name) | Custom script extension name label. | `string` | `"HMCTSVMBootstrap"` | no |
| <a name="input_custom_script_type_handler_version"></a> [custom\_script\_type\_handler\_version](#input\_custom\_script\_type\_handler\_version) | Type handler version number | `string` | `"2.1"` | no |
| <a name="input_custom_script_type_handler_version_windows"></a> [custom\_script\_type\_handler\_version\_windows](#input\_custom\_script\_type\_handler\_version\_windows) | Type handler version number for Windows VMs | `string` | `"1.9"` | no |
| <a name="input_dynatrace_auto_upgrade_minor_version"></a> [dynatrace\_auto\_upgrade\_minor\_version](#input\_dynatrace\_auto\_upgrade\_minor\_version) | Specifies if the platform deploys the latest minor version Dynatrace OneAgent update to the type\_handler\_version specified. | `bool` | `true` | no |
| <a name="input_dynatrace_hostgroup"></a> [dynatrace\_hostgroup](#input\_dynatrace\_hostgroup) | Define the hostgroup to which the VM belongs. | `string` | `null` | no |
| <a name="input_dynatrace_network_zone"></a> [dynatrace\_network\_zone](#input\_dynatrace\_network\_zone) | the network zone the oneagent is attached to i.e azure.cft | `string` | `"azure.cft"` | no |
| <a name="input_dynatrace_server"></a> [dynatrace\_server](#input\_dynatrace\_server) | The server URL, if you want to configure an alternative communication endpoint. | `string` | `null` | no |
| <a name="input_dynatrace_tenant_id"></a> [dynatrace\_tenant\_id](#input\_dynatrace\_tenant\_id) | The tenant ID of your Dynatrace environment. | `string` | `""` | no |
| <a name="input_dynatrace_token"></a> [dynatrace\_token](#input\_dynatrace\_token) | The API token of your Dynatrace environment. | `string` | `""` | no |
| <a name="input_dynatrace_type_handler_version"></a> [dynatrace\_type\_handler\_version](#input\_dynatrace\_type\_handler\_version) | Version of Dynatrace OneAgent - To find: az vm extension image list --location uksouth -p dynatrace.ruxit -o table | `string` | `"2.200"` | no |
| <a name="input_enable_winrm"></a> [enable\_winrm](#input\_enable\_winrm) | Enable WinRM for Windows VMs. Used by Ansible. | `bool` | `false` | no |
| <a name="input_endpoint_protection_handler_version"></a> [endpoint\_protection\_handler\_version](#input\_endpoint\_protection\_handler\_version) | Enable Antimalware Protection. | `string` | `"1.6"` | no |
| <a name="input_endpoint_protection_upgrade_minor_version"></a> [endpoint\_protection\_upgrade\_minor\_version](#input\_endpoint\_protection\_upgrade\_minor\_version) | Specifies if the platform deploys the latest minor version Endpoint Protection update to the type\_handler\_version specified. | `bool` | `true` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name. | `string` | n/a | yes |
| <a name="input_install_azure_monitor"></a> [install\_azure\_monitor](#input\_install\_azure\_monitor) | Install Azure Monitor Agent. | `bool` | `true` | no |
| <a name="input_install_docker"></a> [install\_docker](#input\_install\_docker) | Should Docker and Docker Compose be installed -- Ubuntu only | `bool` | `false` | no |
| <a name="input_install_dynatrace_oneagent"></a> [install\_dynatrace\_oneagent](#input\_install\_dynatrace\_oneagent) | Install Dynatrace OneAgent. | `bool` | `true` | no |
| <a name="input_install_endpoint_protection"></a> [install\_endpoint\_protection](#input\_install\_endpoint\_protection) | Install Endpoint Protection. | `bool` | `true` | no |
| <a name="input_install_nessus_agent"></a> [install\_nessus\_agent](#input\_install\_nessus\_agent) | Install Nessus Agent. | `bool` | `true` | no |
| <a name="input_install_splunk_uf"></a> [install\_splunk\_uf](#input\_install\_splunk\_uf) | Install Splunk UF. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The region in Azure that the Data collection rule will be deployed to. | `string` | `"UK South"` | no |
| <a name="input_nessus_groups"></a> [nessus\_groups](#input\_nessus\_groups) | Nessus group name. | `string` | `"Platform-Operation-Bastions"` | no |
| <a name="input_nessus_key"></a> [nessus\_key](#input\_nessus\_key) | Nessus linking key - read input from keyvault. | `string` | `null` | no |
| <a name="input_nessus_server"></a> [nessus\_server](#input\_nessus\_server) | Nessus server endpoint - read input from keyvault. | `string` | `""` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Windows or Linux. | `string` | `"Linux"` | no |
| <a name="input_rc_auto_upgrade_minor_version"></a> [rc\_auto\_upgrade\_minor\_version](#input\_rc\_auto\_upgrade\_minor\_version) | n/a | `bool` | `false` | no |
| <a name="input_rc_os_sku"></a> [rc\_os\_sku](#input\_rc\_os\_sku) | n/a | `any` | `null` | no |
| <a name="input_rc_script_file"></a> [rc\_script\_file](#input\_rc\_script\_file) | A path to a local file for the script | `any` | `null` | no |
| <a name="input_realtimeprotectionenabled"></a> [realtimeprotectionenabled](#input\_realtimeprotectionenabled) | Enable Realtime Protection | `string` | `true` | no |
| <a name="input_run_cis"></a> [run\_cis](#input\_run\_cis) | Install CIS hardening using run command script? | `bool` | `false` | no |
| <a name="input_run_command"></a> [run\_command](#input\_run\_command) | n/a | `bool` | `false` | no |
| <a name="input_run_command_sa_key"></a> [run\_command\_sa\_key](#input\_run\_command\_sa\_key) | SA key for the run command | `string` | `""` | no |
| <a name="input_run_command_settings"></a> [run\_command\_settings](#input\_run\_command\_settings) | The settings passed to the Run Command extension, these are specified as a JSON object in a string. | `string` | `null` | no |
| <a name="input_run_command_type_handler_version"></a> [run\_command\_type\_handler\_version](#input\_run\_command\_type\_handler\_version) | Type handler version number | `string` | `"1.0"` | no |
| <a name="input_run_command_type_handler_version_windows"></a> [run\_command\_type\_handler\_version\_windows](#input\_run\_command\_type\_handler\_version\_windows) | Type handler version number for Windows VMs | `string` | `"1.1"` | no |
| <a name="input_run_xdr_agent"></a> [run\_xdr\_agent](#input\_run\_xdr\_agent) | Install XDR agents using run command script? | `bool` | `false` | no |
| <a name="input_run_xdr_collector"></a> [run\_xdr\_collector](#input\_run\_xdr\_collector) | Install XDR collectors using run command script? | `bool` | `false` | no |
| <a name="input_scheduledscansettings"></a> [scheduledscansettings](#input\_scheduledscansettings) | Enable Scanning | `map(string)` | <pre>{<br/>  "day": "7",<br/>  "isEnabled": "true",<br/>  "scanType": "Quick",<br/>  "time": "120"<br/>}</pre> | no |
| <a name="input_soc_vault_name"></a> [soc\_vault\_name](#input\_soc\_vault\_name) | The name of the SOC Key Vault. | `string` | `"soc-prod"` | no |
| <a name="input_soc_vault_rg"></a> [soc\_vault\_rg](#input\_soc\_vault\_rg) | The name of the resource group where the SOC Key Vault is located. | `string` | `"soc-core-infra-prod-rg"` | no |
| <a name="input_splunk_group"></a> [splunk\_group](#input\_splunk\_group) | Splunk universal forwarder global target group. | `string` | `"hmcts_forwarders"` | no |
| <a name="input_splunk_pass4symmkey"></a> [splunk\_pass4symmkey](#input\_splunk\_pass4symmkey) | Splunk universal forwarder communication security key - read input from keyvault. | `string` | `null` | no |
| <a name="input_splunk_password"></a> [splunk\_password](#input\_splunk\_password) | Splunk universal forwarder local admin password - read input from keyvault. | `string` | `null` | no |
| <a name="input_splunk_username"></a> [splunk\_username](#input\_splunk\_username) | Splunk universal forwarder local admin username - read input from keyvault. | `string` | `null` | no |
| <a name="input_virtual_machine_id"></a> [virtual\_machine\_id](#input\_virtual\_machine\_id) | Virtual machine resource id. | `string` | `null` | no |
| <a name="input_virtual_machine_scale_set_id"></a> [virtual\_machine\_scale\_set\_id](#input\_virtual\_machine\_scale\_set\_id) | Virtual machine scale set resource id. | `string` | `null` | no |
| <a name="input_virtual_machine_type"></a> [virtual\_machine\_type](#input\_virtual\_machine\_type) | vm or vmss. | `string` | n/a | yes |
| <a name="input_xdr_env"></a> [xdr\_env](#input\_xdr\_env) | Set environment for XDR Agent to make sure which environment it should go to, defaults to prod | `string` | `"prod"` | no |
| <a name="input_xdr_tags"></a> [xdr\_tags](#input\_xdr\_tags) | XDR specific Tags | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_XDR_TAGS"></a> [XDR\_TAGS](#output\_XDR\_TAGS) | n/a |
<!-- END_TF_DOCS -->

## Redhat ELS for RHEL 7.*
This README provides instructions for logging into Redhat ELS, checking the Subscription Manager and Insights-client, and other relevant details.

## Logging into Redhat
To log into Redhat, use the following credentials stored in the Key Vault (KV):

Username: lss-sre@hmcts.net
Password: https://portal.azure.com/#@HMCTS.NET/asset/Microsoft_Azure_KeyVault/Secret/https://acmedcdcnpdev.vault.azure.net/secrets/redhat-portal/cd61d615bffe415f8dd6c1907df3115b


## Certificate Information
The certificate is placed under the following directory:
/etc/pki/product/204.pem

## Checking Subscription Manager and Insights-client Installation
Ensure that both the Subscription Manager and Insights-client are installed correctly and show an active status.

## Inventory Check
You can verify the status of both Subscription Manager and Insights-client by visiting the following inventory link:

https://console.redhat.com/insights/inventory

Both Subscription Manager and Insights-client should display an active status.

Documentation links - https://tools.hmcts.net/confluence/display/~thomas.thornton/RHEL+7+ELS+Support

For more detailed documentation, please refer to the RHEL 7 ELS Support Documentation.