data "azurerm_key_vault" "cnp_vault" {
  provider            = azurerm.cnp
  name                = "infra-vault-${var.env}"
  resource_group_name = var.cnp_vault_rg
}

data "azurerm_key_vault_secret" "token" {
  provider     = azurerm.cnp
  name         = "dynatrace-${var.env}-token"
  key_vault_id = data.azurerm_key_vault.cnp_vault.id
}

data "azurerm_key_vault" "soc_vault" {
  provider            = azurerm.soc
  name                = "soc-${var.env}"
  resource_group_name = "${var.soc_vault_rg}-rg"
}

# Splunk UF
data "azurerm_key_vault_secret" "splunk_username" {
  provider     = azurerm.soc
  name         = var.splunk_username_secret
  key_vault_id = data.azurerm_key_vault.soc_vault.id
}

data "azurerm_key_vault_secret" "splunk_password" {
  provider     = azurerm.soc
  name         = var.splunk_password_secret
  key_vault_id = data.azurerm_key_vault.soc_vault.id
}

data "azurerm_key_vault_secret" "splunk_pass4symmkey" {
  provider     = azurerm.soc
  name         = var.splunk_pass4symmkey_secret
  key_vault_id = data.azurerm_key_vault.soc_vault.id
}

data "azurerm_key_vault_secret" "nessus_agent_key" {
  provider = azurerm.soc

  name         = var.nessus_key_secret
  key_vault_id = data.azurerm_key_vault.soc_vault.id
}