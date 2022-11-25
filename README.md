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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_machine_extension.azure_monitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.custom_script](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.dynatrace_oneagent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.run_command](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.endpoint_protection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.azure_monitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.custom_script](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.dynatrace_oneagent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.run_command](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.endpoint_protection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_script_path"></a> [additional\_script\_path](#input\_additional\_script\_path) | Path to additional script. | `string` | `null` | no |
| <a name="input_additional_script_uri"></a> [additional\_script\_uri](#input\_additional\_script\_uri) | Uri to additional script. Specify <b>additional_script_name</b> when using this | `string` | `null` | no |
| <a name="input_additional_script_name"></a> [additional\_script\_name](#input\_additional\_script\_name) | Name of additional script to run, only required when using <b>additional_script_uri</b> | `string` | `null` | no |
| <a name="input_azure_monitor_auto_upgrade_minor_version"></a> [azure\_monitor\_auto\_upgrade\_minor\_version](#input\_azure\_monitor\_auto\_upgrade\_minor\_version) | Specifies if the platform deploys the latest minor version Azure Monitor update to the type\_handler\_version specified. | `bool` | `true` | no |
| <a name="input_azure_monitor_protected_settings"></a> [azure\_monitor\_protected\_settings](#input\_azure\_monitor\_protected\_settings) | The protected\_settings passed to the Azure Monitor extension, like settings, these are specified as a JSON object in a string. | `string` | `null` | no |
| <a name="input_azure_monitor_settings"></a> [azure\_monitor\_settings](#input\_azure\_monitor\_settings) | The settings passed to the Azure Monitor extension, these are specified as a JSON object in a string. | `string` | `null` | no |
| <a name="input_azure_monitor_type_handler_version"></a> [azure\_monitor\_type\_handler\_version](#input\_azure\_monitor\_type\_handler\_version) | Version of Azure Monitor - To find: az vm extension image list --location uksouth -p Microsoft.Azure.Monitor -o table | `string` | `"1.9"` | no |
| <a name="input_custom_script_extension_name"></a> [custom\_script\_extension\_name](#input\_custom\_script\_extension\_name) | Custom script extension name label. | `string` | `"HMCTSVMBootstrap"` | no |
| <a name="input_custom_script_type_handler_version"></a> [custom\_script\_type\_handler\_version](#input\_custom\_script\_type\_handler\_version) | Type handler version number | `string` | `"2.1"` | no |
| <a name="input_custom_script_type_handler_version_windows"></a> [custom\_script\_type\_handler\_version\_windows](#input\_custom\_script\_type\_handler\_version\_windows) | Type handler version number for Windows VMs | `string` | `"1.10"` | no |
| <a name="input_dynatrace_auto_upgrade_minor_version"></a> [dynatrace\_auto\_upgrade\_minor\_version](#input\_dynatrace\_auto\_upgrade\_minor\_version) | Specifies if the platform deploys the latest minor version Dynatrace OneAgent update to the type\_handler\_version specified. | `bool` | `true` | no |
| <a name="input_dynatrace_hostgroup"></a> [dynatrace\_hostgroup](#input\_dynatrace\_hostgroup) | Define the hostgroup to which the VM belongs. | `string` | `null` | no |
| <a name="input_dynatrace_network_zone"></a> [dynatrace\_network\_zone](#input\_dynatrace\_network\_zone) | the network zone the oneagent is attached to i.e azure.cft | `string` | `"azure.cft"` | no |
| <a name="input_dynatrace_server"></a> [dynatrace\_server](#input\_dynatrace\_server) | The server URL, if you want to configure an alternative communication endpoint. | `string` | `null` | no |
| <a name="input_dynatrace_tenant_id"></a> [dynatrace\_tenant\_id](#input\_dynatrace\_tenant\_id) | The Dynatrace environment ID. | `string` | `null` | no |
| <a name="input_dynatrace_token"></a> [dynatrace\_token](#input\_dynatrace\_token) | The Dynatrace PaaS token. | `string` | `null` | no |
| <a name="input_dynatrace_type_handler_version"></a> [dynatrace\_type\_handler\_version](#input\_dynatrace\_type\_handler\_version) | Version of Dynatrace OneAgent - To find: az vm extension image list --location uksouth -p dynatrace.ruxit -o table | `string` | `"2.182"` | no |
| <a name="input_install_azure_monitor"></a> [install\_azure\_monitor](#input\_install\_azure\_monitor) | Install Azure Monitor Agent. | `bool` | `true` | no |
| <a name="input_install_dynatrace_oneagent"></a> [install\_dynatrace\_oneagent](#input\_install\_dynatrace\_oneagent) | Install Dynatrace OneAgent. | `bool` | `true` | no |
| <a name="input_install_nessus_agent"></a> [install\_nessus\_agent](#input\_install\_nessus\_agent) | Install Nessus Agent. | `bool` | `false` | no |
| <a name="input_install_splunk_uf"></a> [install\_splunk\_uf](#input\_install\_splunk\_uf) | Install Splunk UF. | `bool` | `true` | no |
| <a name="input_nessus_groups"></a> [nessus\_groups](#input\_nessus\_groups) | Nessus agent groups. | `string` | `""` | no |
| <a name="input_nessus_key"></a> [nessus\_key](#input\_nessus\_key) | Nessus linking key - read input from keyvault. | `string` | `""` | no |
| <a name="input_nessus_server"></a> [nessus\_server](#input\_nessus\_server) | Nessus server endpoint - read input from keyvault. | `string` | `""` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Windows or Linux. | `string` | `"Linux"` | no |
| <a name="input_splunk_group"></a> [splunk\_group](#input\_splunk\_group) | Splunk universal forwarder global target group. | `string` | `"dynatrace_forwarders"` | no |
| <a name="input_splunk_pass4symmkey"></a> [splunk\_pass4symmkey](#input\_splunk\_pass4symmkey) | Splunk universal forwarder communication security key - read input from keyvault. | `string` | `""` | no |
| <a name="input_splunk_password"></a> [splunk\_password](#input\_splunk\_password) | Splunk universal forwarder local admin password - read input from keyvault. | `string` | `""` | no |
| <a name="input_splunk_username"></a> [splunk\_username](#input\_splunk\_username) | Splunk universal forwarder local admin username - read input from keyvault. | `string` | `""` | no |
| <a name="input_virtual_machine_id"></a> [virtual\_machine\_id](#input\_virtual\_machine\_id) | Virtual machine resource id. | `string` | `null` | no |
| <a name="input_virtual_machine_scale_set_id"></a> [virtual\_machine\_scale\_set\_id](#input\_virtual\_machine\_scale\_set\_id) | Virtual machine scale set resource id. | `string` | `null` | no |
| <a name="input_virtual_machine_type"></a> [virtual\_machine\_type](#input\_virtual\_machine\_type) | vm or vmss. | `string` | n/a | yes |
| <a name="input_run_command"></a> [run\_command](#input\run\_command) | Install Run Command. | `bool` | `false` | no |
| <a name="input_rc_script_file"></a> [rc\_script\_file](#input\rc\_script\_file) | The script file that need to run from scripts folder | `string` | `null` | no |
| <a name="input_install_endpoint_protection"></a> [install\_endpoint\_protection](#input\install\_endpoint\_protection) | Installation of MS Antimalware on Windows | `bool` | `true` | no |
## Outputs

No outputs.