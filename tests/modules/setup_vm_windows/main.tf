module "common_tags" {
  source = "github.com/hmcts/terraform-module-common-tags?ref=master"

  builtFrom   = "hmcts/terraform-module-virtual-machine-scale-set"
  environment = "ptlsbox"
  product     = "sds-platform"
}

# resource "azurerm_resource_group" "test" {
#   name     = "vm-module-test-rg"
#   location = "UK South"
# }