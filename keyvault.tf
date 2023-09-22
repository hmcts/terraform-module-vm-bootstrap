data "azurerm_key_vault" "cnp_vault" {
  count               = var.install_dynatrace_oneagent ? 1 : 0
  provider            = azurerm.cnp
  name                = var.env == "prod" ? "infra-vault-prod" : "infra-vault-nonprod"
  resource_group_name = local.cnp_vault_rg
}

data "azurerm_key_vault_secret" "token" {
  count        = var.install_dynatrace_oneagent ? 1 : 0
  provider     = azurerm.cnp
  name         = "dynatrace-${var.env}-token"
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
  name         = "nessus-agent-key-${var.env}"
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}

#Jenkins MI access to CNP vault
data "azurerm_client_config" "current" {
}

data "azuread_service_principal" "jenkins-mi" {
  display_name = var.env == "sbox" ? "jenkins-ptlsbox-mi" : "jenkins-ptl-mi"
}

resource "azurerm_key_vault_access_policy" "jenkins-access" {
  key_vault_id = data.azurerm_key_vault.cnp_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.jenkins-mi.display_name

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]
}