provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "soc"
  features {}
  subscription_id            = "8ae5b3b6-0b12-4888-b894-4cec33c92292"
  skip_provider_registration = true
}

provider "azurerm" {
  alias = "cnp"
  features {}
  subscription_id            = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
  skip_provider_registration = true
}

# Default variables for this test
variables {
  env     = "nonprod"
  os_type = "Windows"
}

run "setup_vm" {
  module {
    source = "./tests/modules/setup_vmss_windows"
  }
}

# Tests the default settings for extensions for a windows VM
# - Should install azure monitor by default
# - Should install a custom script extension by default (for nessus and splunk)
# - Should install dynatrace by default
# - Should install endpoint protection by default
# - Should not install any scaleset extensions
run "virtual_machine_scale_set_no_extensions" {

  command = plan

  variables {
    virtual_machine_type         = "vmss"
    virtual_machine_scale_set_id = run.setup_vm.vmss_id
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.azure_monitor) == 1
    error_message = "Azure monitor installed by default"
  }

  assert {
    condition     = azurerm_virtual_machine_scale_set_extension.azure_monitor[0].name == "AMAWindows"
    error_message = "Incorrect name for azure monitor extension"
  }

  assert {
    condition     = azurerm_virtual_machine_scale_set_extension.azure_monitor[0].type == "AzureMonitorWindowsAgent"
    error_message = "Incorrect type for azure monitor extension"
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.custom_script) == 1
    error_message = "Custom script not installed by default"
  }

  assert {
    condition     = azurerm_virtual_machine_scale_set_extension.custom_script[0].publisher == "Microsoft.Compute"
    error_message = "Wrong publisher for a windows custom script"
  }

  assert {
    condition     = azurerm_virtual_machine_scale_set_extension.custom_script[0].type == "CustomScriptExtension"
    error_message = "Wrong type for a windows custom script"
  }

  assert {
    condition     = azurerm_virtual_machine_scale_set_extension.custom_script[0].type_handler_version == "1.9"
    error_message = "Wrong type handler version for a windows custom script"
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.dynatrace_oneagent) == 1
    error_message = "Dynatrace not installed by default"
  }

  assert {
    condition     = azurerm_virtual_machine_scale_set_extension.dynatrace_oneagent[0].type == "oneAgentWindows"
    error_message = "Wrong type for windows dynatrace extension"
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.endpoint_protection) == 1
    error_message = "Endpoint protection not installed by default"
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.azure_vmss_run_command) == 0
    error_message = "Run command installed when not specified"
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.azure_monitor) == 0
    error_message = "Scale set extension stood up for VM"
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.custom_script) == 0
    error_message = "Scale set extension stood up for VM"
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.dynatrace_oneagent) == 0
    error_message = "Scale set extension stood up for VM"
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.endpoint_protection) == 0
    error_message = "Scale set extension stood up for VM"
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.azure_vm_run_command) == 0
    error_message = "Scale set extension stood up for VM"
  }
}

# Should not stand up an azure monitor extension when disabled
run "virtual_machine_scale_set_no_azure_monitor_extension" {

  command = plan

  variables {
    virtual_machine_type         = "vmss"
    virtual_machine_scale_set_id = run.setup_vm.vmss_id
    install_azure_monitor        = false
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.azure_monitor) == 0
    error_message = "Azure monitor installed when turned off"
  }
}

# Custom scipt should still install when nessus is disabled but splunk is still enabled
run "virtual_machine_scale_set_no_nessus" {

  command = plan

  variables {
    virtual_machine_type         = "vmss"
    virtual_machine_scale_set_id = run.setup_vm.vmss_id
    install_nessus_agent         = false
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.custom_script) == 1
    error_message = "Custom script not installed when only nessus is disabled"
  }
}

# Custom scipt should still install when splunk is disabled but nessus is still enabled
run "virtual_machine_scale_set_no_splunk" {

  command = plan

  variables {
    virtual_machine_type         = "vmss"
    virtual_machine_scale_set_id = run.setup_vm.vmss_id
    install_splunk_uf            = false
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.custom_script) == 1
    error_message = "Custom script not installed when only nessus is disabled"
  }
}

# Custom scipt should not install endpoint protection when disabled
run "virtual_machine_scale_set_no_endpoint_protection" {

  command = plan

  variables {
    virtual_machine_type         = "vmss"
    virtual_machine_scale_set_id = run.setup_vm.vmss_id
    install_endpoint_protection  = false
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.endpoint_protection) == 0
    error_message = "Endpoint protection installed when disabled"
  }
}

# Custom scipt should not be installed when both nessus and splunk are disabled
# TODO: add a test for additional script as that is installed here as well
# TODO: add tests for run command
run "virtual_machine_scale_set_no_nessus_or_splunk" {

  command = plan

  variables {
    virtual_machine_type         = "vmss"
    virtual_machine_scale_set_id = run.setup_vm.vmss_id
    install_splunk_uf            = false
    install_nessus_agent         = false
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.custom_script) == 0
    error_message = "Custom script installed when nessus and splunk are disabled"
  }
}

# Custom scipt should still install when splunk is disabled but nessus is still enabled
run "virtual_machine_scale_set_no_dynatrace" {

  command = plan

  variables {
    virtual_machine_type         = "vmss"
    virtual_machine_scale_set_id = run.setup_vm.vmss_id
    install_dynatrace_oneagent   = false
  }

  assert {
    condition     = length(azurerm_virtual_machine_scale_set_extension.dynatrace_oneagent) == 0
    error_message = "Dynatrace installed when disabled"
  }
}