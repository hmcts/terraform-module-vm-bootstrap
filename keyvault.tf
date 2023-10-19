data "azurerm_key_vault" "cnp_vault" {
  count               = var.install_dynatrace_oneagent ? 1 : 0
  provider            = azurerm.cnp
  name                = var.env == "prod" ? "infra-vault-prod" : "infra-vault-nonprod"
  resource_group_name = local.cnp_vault_rg
}

data "azurerm_key_vault_secret" "token" {
  count        = var.install_dynatrace_oneagent ? 1 : 0
  provider     = azurerm.cnp
  name         = var.env == "prod" ? "dynatrace-prod-token" : "dynatrace-nonprod-token"
  key_vault_id = data.azurerm_key_vault.cnp_vault[0].id
}

data "azurerm_key_vault" "soc_vault" {
  count               = var.install_nessus_agent || var.install_splunk_uf ? 1 : 0
  provider            = azurerm.soc
  name                = var.soc_vault_name
  resource_group_name = var.soc_vault_rg
}

# Splunk UF
data "azurerm_key_vault_secret" "splunk_username" {
  count        = var.install_splunk_uf ? 1 : 0
  provider     = azurerm.soc
  name         = "splunk-gui-admin-username"
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}

data "azurerm_key_vault_secret" "splunk_password" {
  count        = var.install_splunk_uf ? 1 : 0
  provider     = azurerm.soc
  name         = "splunk-gui-admin-password"
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}

data "azurerm_key_vault_secret" "splunk_pass4symmkey" {
  count        = var.install_splunk_uf ? 1 : 0
  provider     = azurerm.soc
  name         = "splunk-pass4symmkey"
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}

data "azurerm_key_vault_secret" "nessus_agent_key" {
  count        = var.install_nessus_agent ? 1 : 0
  provider     = azurerm.soc
  name         = var.nessus_key ? "" : "nessus-agent-key-${var.env}"
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}
