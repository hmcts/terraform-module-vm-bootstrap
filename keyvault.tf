# Dynatrace OneAgent
data "azurerm_key_vault" "cnp_vault" {
  provider = azurerm.cnp

  name                = "infra-vault-${local.dynatrace_env}"
  resource_group_name = var.cnp_vault_rg
}

data "azurerm_key_vault_secret" "token" {
  provider = azurerm.cnp

  name         = "dynatrace-${local.dynatrace_env}-token"
  key_vault_id = data.azurerm_key_vault.cnp_vault.id
}

data "azurerm_key_vault" "soc_vault" {
  provider = azurerm.soc

  name                = var.soc_vault_name
  resource_group_name = var.soc_vault_rg
}

# Splunk UF
data "azurerm_key_vault_secret" "splunk_username" {
  provider = azurerm.soc

  name         = var.splunk_username_secret
  key_vault_id = data.azurerm_key_vault.soc_vault.id
}

data "azurerm_key_vault_secret" "splunk_password" {
  provider = azurerm.soc

  name         = var.splunk_password_secret
  key_vault_id = data.azurerm_key_vault.soc_vault.id
}
