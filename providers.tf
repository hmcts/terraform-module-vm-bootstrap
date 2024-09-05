terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.cnp, azurerm.soc]
    }
  }
}

provider "azurerm" {
  alias = "dcr"
  features {}
  subscription_id = local.log_analytics_subscription
}
