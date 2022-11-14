# VM/VMSS Extension General
variable "common_tags" {
  description = "Common Tags"
  type        = map(string)
  default     = null
}

variable "os_type" {
  description = "Windows or Linux."
  type        = string
  default     = "Linux"
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
  default     = "2.182"
}

variable "dynatrace_hostgroup" {
  description = "Define the hostgroup to which the VM belongs."
  type        = string
  default     = ""
}

variable "dynatrace_network_zone" {
  description = "the network zone the oneagent is attached to i.e azure.cft"
  type        = string
  default     = "azure.cft"
}

variable "dynatrace_tenant_id" {
  description = "The Dynatrace environment ID."
  type        = string
  default     = ""
}

variable "dynatrace_token" {
  description = "The Dynatrace PaaS token."
  type        = string
  default     = ""
}

variable "dynatrace_server" {
  description = "The server URL, if you want to configure an alternative communication endpoint."
  type        = string
  default     = ""
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
  default     = ""
}

variable "nessus_groups" {
  description = "Nessus agent groups."
  type        = string
  default     = ""
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
  default     = ""
}

variable "splunk_password" {
  description = "Splunk universal forwarder local admin password - read input from keyvault."
  type        = string
  default     = ""
}

variable "splunk_pass4symmkey" {
  description = "Splunk universal forwarder communication security key - read input from keyvault."
  type        = string
  default     = ""
}

variable "splunk_group" {
  description = "Splunk universal forwarder global target group."
  type        = string
  default     = "hmcts_forwarders"
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

variable "rc_vm_name" {
  default = null
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