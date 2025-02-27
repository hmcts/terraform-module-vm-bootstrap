
# VM/VMSS Extension General
variable "common_tags" {
  description = "Common Tags"
  type        = map(string)
  default     = null
}


variable "xdr_tags" {
  description = "XDR specific Tags"
  type        = string
  default     = ""
}

variable "os_type" {
  description = "Windows or Linux."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["windows", "linux"], lower(var.os_type))
    error_message = "Unknown OS type. Must be either 'Windows' or 'Linux'"
  }
}

variable "env" {
  description = "Environment name."
  type        = string

}

variable "virtual_machine_id" {
  description = "Virtual machine resource id."
  type        = string
  default     = null
}

variable "virtual_machine_scale_set_id" {
  description = "Virtual machine scale set resource id."
  type        = string
  default     = null
}

variable "virtual_machine_type" {
  description = "vm or vmss."
  type        = string
}

# Azure Monitor
variable "install_azure_monitor" {
  description = "Install Azure Monitor Agent."
  type        = bool
  default     = true
}

variable "azure_monitor_auto_upgrade_minor_version" {
  description = "Specifies if the platform deploys the latest minor version Azure Monitor update to the type_handler_version specified."
  type        = bool
  default     = true
}

variable "azure_monitor_type_handler_version" {
  description = "Version of Azure Monitor - To find: az vm extension image list --location uksouth -p Microsoft.Azure.Monitor -o table"
  type        = string
  default     = "1.9"
}

variable "azure_monitor_settings" {
  description = "The settings passed to the Azure Monitor extension, these are specified as a JSON object in a string."
  type        = string
  default     = null
}

variable "azure_monitor_protected_settings" {
  description = "The protected_settings passed to the Azure Monitor extension, like settings, these are specified as a JSON object in a string."
  type        = string
  default     = null
}

# Custom Script
variable "additional_script_path" {
  description = "Path to additional script."
  default     = null
}

variable "additional_script_uri" {
  description = "Uri download link to additional script"
  default     = null
}

variable "additional_script_name" {
  description = "Additional script name when using script additional_script_uri."
  default     = null
}

variable "custom_script_extension_name" {
  description = "Custom script extension name label."
  type        = string
  default     = "HMCTSVMBootstrap"
}

variable "custom_script_type_handler_version" {
  description = "Type handler version number"
  type        = string
  default     = "2.1"
}

variable "custom_script_type_handler_version_windows" {
  description = "Type handler version number for Windows VMs"
  type        = string
  default     = "1.9"
}

# Dynatrace OneAgent
variable "install_dynatrace_oneagent" {
  description = "Install Dynatrace OneAgent."
  type        = bool
  default     = true
}

variable "dynatrace_auto_upgrade_minor_version" {
  description = "Specifies if the platform deploys the latest minor version Dynatrace OneAgent update to the type_handler_version specified."
  type        = bool
  default     = true
}

variable "dynatrace_type_handler_version" {
  description = "Version of Dynatrace OneAgent - To find: az vm extension image list --location uksouth -p dynatrace.ruxit -o table"
  type        = string
  default     = "2.200"
}

variable "dynatrace_hostgroup" {
  description = "Define the hostgroup to which the VM belongs."
  type        = string
  default     = null
}

variable "dynatrace_network_zone" {
  description = "the network zone the oneagent is attached to i.e azure.cft"
  type        = string
  default     = "azure.cft"
}

variable "dynatrace_tenant_id" {
  description = "The tenant ID of your Dynatrace environment."
  type        = string
  default     = ""
}

variable "dynatrace_token" {
  description = "The API token of your Dynatrace environment."
  type        = string
  default     = ""
}

variable "dynatrace_server" {
  description = "The server URL, if you want to configure an alternative communication endpoint."
  type        = string
  default     = null
}

variable "dynatrace_custom_hostname" {
  description = "Manually set the hostname of the vm on the web interface."
  type        = string
  default     = null
}

# Nessus Agent
variable "install_nessus_agent" {
  description = "Install Nessus Agent."
  type        = bool
  default     = true
}

variable "nessus_server" {
  description = "Nessus server endpoint - read input from keyvault."
  type        = string
  default     = ""
}

variable "nessus_key" {
  description = "Nessus linking key - read input from keyvault."
  type        = string
  default     = null
}

variable "nessus_groups" {
  description = "Nessus group name."
  type        = string
  default     = "Platform-Operation-Bastions"
}

# Splunk UF
variable "install_splunk_uf" {
  description = "Install Splunk UF."
  default     = true
  type        = bool
}

variable "splunk_username" {
  description = "Splunk universal forwarder local admin username - read input from keyvault."
  type        = string
  default     = null
}

variable "splunk_password" {
  description = "Splunk universal forwarder local admin password - read input from keyvault."
  type        = string
  default     = null
}

variable "splunk_pass4symmkey" {
  description = "Splunk universal forwarder communication security key - read input from keyvault."
  type        = string
  default     = null
}

variable "splunk_group" {
  description = "Splunk universal forwarder global target group."
  type        = string
  default     = "hmcts_forwarders"
}

# Endpoint Protection
variable "install_endpoint_protection" {
  description = "Install Endpoint Protection."
  type        = bool
  default     = true
}

variable "endpoint_protection_handler_version" {
  description = "Enable Antimalware Protection."
  type        = string
  default     = "1.6"
}

variable "endpoint_protection_upgrade_minor_version" {
  description = "Specifies if the platform deploys the latest minor version Endpoint Protection update to the type_handler_version specified."
  type        = bool
  default     = true
}

variable "antimalwareenabled" {
  description = "Enable AntiMalware Protection"
  type        = string
  default     = true
}

variable "realtimeprotectionenabled" {
  description = "Enable Realtime Protection"
  type        = string
  default     = true
}

variable "scheduledscansettings" {
  description = "Enable Scanning"
  type        = map(string)
  default = {
    isEnabled = "true"
    day       = "7"
    time      = "120"
    scanType  = "Quick"
  }
}

# Run Command Variables

variable "run_command" {
  type    = bool
  default = false
}


variable "run_command_settings" {
  description = "The settings passed to the Run Command extension, these are specified as a JSON object in a string."
  type        = string
  default     = null
}


variable "rc_auto_upgrade_minor_version" {
  type    = bool
  default = false
}


variable "rc_script_file" {
  description = "A path to a local file for the script"
  default     = null
}

variable "run_command_type_handler_version" {
  description = "Type handler version number"
  type        = string
  default     = "1.0"
}

variable "run_command_type_handler_version_windows" {
  description = "Type handler version number for Windows VMs"
  type        = string
  default     = "1.1"
}

variable "rc_os_sku" {
  default = null
}

variable "additional_script_mi_id" {
  description = "This variable will be used to pass Managed Identity ID when the additional script has been used"
  default     = null
}

variable "cnp_vault_rg" {
  description = "The name of the resource group where the CNP Key Vault is located."
  type        = string
  default     = null
}

variable "soc_vault_rg" {
  description = "The name of the resource group where the SOC Key Vault is located."
  type        = string
  default     = "soc-core-infra-prod-rg"
}

variable "soc_vault_name" {
  description = "The name of the SOC Key Vault."
  type        = string
  default     = "soc-prod"
}

variable "run_command_sa_key" {
  description = "SA key for the run command"
  default     = ""
  sensitive   = true
}

variable "run_cis" {
  type        = bool
  default     = false
  description = "Install CIS hardening using run command script?"
}
variable "run_xdr_collector" {
  type        = bool
  default     = false
  description = "Install XDR collectors using run command script?"
}

variable "run_xdr_agent" {
  type        = bool
  default     = false
  description = "Install XDR agents using run command script?"
}

variable "xdr_env" {
  description = "Set environment for XDR Agent to make sure which environment it should go to, defaults to prod"
  type        = string
  default     = "prod"
}

variable "install_docker" {
  description = "Should Docker and Docker Compose be installed -- Ubuntu only"
  type        = bool
  default     = false
}

variable "enable_winrm" {
  description = "Enable WinRM for Windows VMs. Used by Ansible."
  type        = bool
  default     = false
}

variable "location" {
  description = "The region in Azure that the Data collection rule will be deployed to."
  type        = string
  default     = "UK South"
}
