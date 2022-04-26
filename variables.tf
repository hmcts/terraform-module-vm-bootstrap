# VM/VMSS Extension General
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

variable "azure_monitor_automatic_upgrade_enabled" {
  description = "Should the Extension be automatically updated whenever the Publisher releases a new version of this VM Extension?"
  type        = bool
  default     = false
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
  type        = string
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

variable "dynatrace_oneagent_auto_upgrade_minor_version" {
  description = "Specifies if the platform deploys the latest minor version Dynatrace OneAgent update to the type_handler_version specified."
  type        = bool
  default     = true
}

variable "dynatrace_oneagent_automatic_upgrade_enabled" {
  description = "Should the Extension be automatically updated whenever the Publisher releases a new version of this VM Extension?"
  type        = bool
  default     = false
}

variable "dynatrace_oneagent_type_handler_version" {
  description = "Version of Dynatrace OneAgent - To find: az vm extension image list --location uksouth -p dynatrace.ruxit -o table"
  type        = string
  default     = "2.182"
}

variable "hostgroup" {
  description = "Define the hostgroup to which the VM belongs."
  type        = string
  default     = null
}

variable "network_zone" {
  description = "the network zone the oneagent is attached to i.e azure.cft"
  type        = string
  default     = "azure.cft"
}

variable "tenant_id" {
  description = "The Dynatrace environment ID."
  type        = string
  default     = null
}

variable "token" {
  description = "The Dynatrace PaaS token."
  type        = string
  default     = null
}

variable "server" {
  description = "The server URL, if you want to configure an alternative communication endpoint."
  type        = string
  default     = null
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
  default     = "dynatrace_forwarders"
}