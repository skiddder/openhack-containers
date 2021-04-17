provider "azurerm" {
    subscription_id = var.subscription_id
    # client_id       = var.terraform_client_id
    # client_secret   = var.terraform_client_secret
    tenant_id       = var.tenant_id
    version = "=2.43.0"
    features {}
}

data "azurerm_client_config" "current" {
}

####################### Locals block for hardcoded names. ################## 
locals {
    prefix                         = "${var.customer}-${var.prefix}-${var.env_name}"
    aks_name                       = "${local.prefix}-aks"
    aks_nodepool_1_name            = "agentpool"
    aks_node_rg_name               = "${local.aks_name}-nodes-rg"

    logs_name                      = "${local.prefix}-law"

    acr_name                       = "${local.prefix}acr"
}

########################## get secrets from keyvault ################
data "azurerm_log_analytics_workspace" "law_aks_logs" {
  name                = ""
  resource_group_name = ""
}

data "azurerm_key_vault_secret" "mariadb-login" {
  name = "mariadb-login"
  key_vault_id = var.keyvault_id
}
data "azurerm_key_vault_secret" "mariadb-pw" {
  name = "mariadb-pw"
  key_vault_id = var.keyvault_id
}
data "azurerm_public_ip" "fw-pip" {
  name                = "${local.prefix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
}

########################## create target resource group ################
resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = var.location
}