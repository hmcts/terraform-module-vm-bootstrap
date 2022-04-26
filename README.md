# terraform-module-vm-bootstrap

A Terraform module for bootstrapping Linux of Windows Virtual Machines or Virtual Machine Scale Sets via supported agents and/custom scripts.

Supported Agents:

- Azure Monitor
- Dynatrace OneAgent
- Splunk Universal Forwarder

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
| [azurerm_virtual_machine_scale_set_extension.azure_monitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.custom_script](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_virtual_machine_scale_set_extension.dynatrace_oneagent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_script_path"></a> [additional\_script\_path](#input\_additional\_script\_path) | Path to additional script. | `string` | `null` | no |
| <a name="input_azure_monitor_auto_upgrade_minor_version"></a> [azure\_monitor\_auto\_upgrade\_minor\_version](#input\_azure\_monitor\_auto\_upgrade\_minor\_version) | Specifies if the platform deploys the latest minor version Azure Monitor update to the type\_handler\_version specified. | `bool` | `true` | no |
| <a name="input_azure_monitor_automatic_upgrade_enabled"></a> [azure\_monitor\_automatic\_upgrade\_enabled](#input\_azure\_monitor\_automatic\_upgrade\_enabled) | Should the Extension be automatically updated whenever the Publisher releases a new version of this VM Extension? | `bool` | `false` | no |
| <a name="input_azure_monitor_protected_settings"></a> [azure\_monitor\_protected\_settings](#input\_azure\_monitor\_protected\_settings) | The protected\_settings passed to the Azure Monitor extension, like settings, these are specified as a JSON object in a string. | `string` | `null` | no |
| <a name="input_azure_monitor_settings"></a> [azure\_monitor\_settings](#input\_azure\_monitor\_settings) | The settings passed to the Azure Monitor extension, these are specified as a JSON object in a string. | `string` | `null` | no |
| <a name="input_azure_monitor_type_handler_version"></a> [azure\_monitor\_type\_handler\_version](#input\_azure\_monitor\_type\_handler\_version) | Version of Azure Monitor - To find: az vm extension image list --location uksouth -p Microsoft.Azure.Monitor -o table | `string` | `"1.9"` | no |
| <a name="input_custom_script_extension_name"></a> [custom\_script\_extension\_name](#input\_custom\_script\_extension\_name) | Custom script extension name label. | `string` | `"HMCTSBootstrapVM"` | no |
| <a name="input_custom_script_type_handler_version"></a> [custom\_script\_type\_handler\_version](#input\_custom\_script\_type\_handler\_version) | Type handler version number | `string` | `"2.1"` | no |
| <a name="input_custom_script_type_handler_version_windows"></a> [custom\_script\_type\_handler\_version\_windows](#input\_custom\_script\_type\_handler\_version\_windows) | Type handler version number for Windows VMs | `string` | `"1.9"` | no |
| <a name="input_dynatrace_oneagent_auto_upgrade_minor_version"></a> [dynatrace\_oneagent\_auto\_upgrade\_minor\_version](#input\_dynatrace\_oneagent\_auto\_upgrade\_minor\_version) | Specifies if the platform deploys the latest minor version Dynatrace OneAgent update to the type\_handler\_version specified. | `bool` | `true` | no |
| <a name="input_dynatrace_oneagent_automatic_upgrade_enabled"></a> [dynatrace\_oneagent\_automatic\_upgrade\_enabled](#input\_dynatrace\_oneagent\_automatic\_upgrade\_enabled) | Should the Extension be automatically updated whenever the Publisher releases a new version of this VM Extension? | `bool` | `false` | no |
| <a name="input_dynatrace_oneagent_type_handler_version"></a> [dynatrace\_oneagent\_type\_handler\_version](#input\_dynatrace\_oneagent\_type\_handler\_version) | Version of Dynatrace OneAgent - To find: az vm extension image list --location uksouth -p dynatrace.ruxit -o table | `string` | `"2.182"` | no |
| <a name="input_hostgroup"></a> [hostgroup](#input\_hostgroup) | Define the hostgroup to which the VM belongs. | `string` | `null` | no |
| <a name="input_install_azure_monitor"></a> [install\_azure\_monitor](#input\_install\_azure\_monitor) | Install Azure Monitor Agent. | `bool` | `true` | no |
| <a name="input_install_dynatrace_oneagent"></a> [install\_dynatrace\_oneagent](#input\_install\_dynatrace\_oneagent) | Install Dynatrace OneAgent. | `bool` | `true` | no |
| <a name="input_install_splunk_uf"></a> [install\_splunk\_uf](#input\_install\_splunk\_uf) | Install Splunk UF. | `bool` | `true` | no |
| <a name="input_network_zone"></a> [network\_zone](#input\_network\_zone) | the network zone the oneagent is attached to i.e azure.cft | `string` | `"azure.cft"` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Windows or Linux. | `string` | `"Linux"` | no |
| <a name="input_server"></a> [server](#input\_server) | The server URL, if you want to configure an alternative communication endpoint. | `string` | `null` | no |
| <a name="input_splunk_group"></a> [splunk\_group](#input\_splunk\_group) | Splunk universal forwarder global target group. | `string` | `"dynatrace_forwarders"` | no |
| <a name="input_splunk_pass4symmkey"></a> [splunk\_pass4symmkey](#input\_splunk\_pass4symmkey) | Splunk universal forwarder communication security key - read input from keyvault. | `string` | `null` | no |
| <a name="input_splunk_password"></a> [splunk\_password](#input\_splunk\_password) | Splunk universal forwarder local admin password - read input from keyvault. | `string` | `null` | no |
| <a name="input_splunk_username"></a> [splunk\_username](#input\_splunk\_username) | Splunk universal forwarder local admin username - read input from keyvault. | `string` | `null` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Dynatrace environment ID. | `string` | `null` | no |
| <a name="input_token"></a> [token](#input\_token) | The Dynatrace PaaS token. | `string` | `null` | no |
| <a name="input_virtual_machine_id"></a> [virtual\_machine\_id](#input\_virtual\_machine\_id) | Virtual machine resource id. | `string` | `null` | no |
| <a name="input_virtual_machine_scale_set_id"></a> [virtual\_machine\_scale\_set\_id](#input\_virtual\_machine\_scale\_set\_id) | Virtual machine scale set resource id. | `string` | `null` | no |
| <a name="input_virtual_machine_type"></a> [virtual\_machine\_type](#input\_virtual\_machine\_type) | vm or vmss. | `string` | n/a | yes |

## Outputs

No outputs.