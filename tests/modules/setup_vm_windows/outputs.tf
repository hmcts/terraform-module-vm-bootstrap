output "location" {
  value = azurerm_resource_group.test.location
}

output "resource_group" {
  value = azurerm_resource_group.test.name
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.id
}