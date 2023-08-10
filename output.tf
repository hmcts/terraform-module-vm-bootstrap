output "splunk_username" { 
    value = data.azurerm_key_vault_secret.splunk_username.value
}