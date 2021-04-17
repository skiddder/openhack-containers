#!/bin/bash
KEYVAULT_NAME="ohcontainer-kv"
RESOURCE_GROUP="ohcontainer-rg"
REGION="westeurope"
SQL_SERVER="sqlservervnb0999.database.windows.net"
SQL_USER="sqladminvNb0999"
SQL_PW="vX6gw9Ec6"
SQL_DB="mydrivingDB"

#az keyvault create -g $RESOURCE_GROUP -l $RESOURCE_GROUP -n $KEYVAULT_NAME

# OPTION 4 - VMSS System Assigned Managed Identity
# go to your VMSS in portal and in Identity settings activate System Assigned Managed Identity and note down the objectId or use the following cmd:
# az vmss identity show -g <resource group>  -n <vmss scalset name> -o yaml
OBJECT_ID="2085af87-00e2-4ede-9fc4-190fe27ac858" 

# set policy to access keys in your Key Vault
az keyvault set-policy -n $KEYVAULT_NAME --key-permissions get --object-id $OBJECT_ID
# set policy to access secrets in your Key Vault
az keyvault set-policy -n $KEYVAULT_NAME --secret-permissions get --object-id $OBJECT_ID
# set policy to access certs in your Key Vault
az keyvault set-policy -n $KEYVAULT_NAME --certificate-permissions get --object-id $OBJECT_ID

# set keyvault secrets
#az keyvault secret set --name "SQL-SERVER" --value $SQL_SERVER --vault-name $KEYVAULT_NAME
#az keyvault secret set --name "SQL-USER" --value $SQL_USER --vault-name $KEYVAULT_NAME
#az keyvault secret set --name "SQL-PASSWORD" --value $SQL_PW --vault-name $KEYVAULT_NAME
#az keyvault secret set --name "SQL-DBNAME" --value $SQL_DB --vault-name $KEYVAULT_NAME
