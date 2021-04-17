#!/bin/bash

# should be an address space that is within the vnet adddress space
# but does not overlap with any other subnet address space
addressPrefix="10.2.2.0/23"
clusterName="ohcontainer2"

# Create subnet for AKS cluster
SUBNET_ID=$(az network vnet subnet create -n aks2 -g ohcontainer-rg --vnet-name vnet --address-prefix $addressPrefix --query "id" -o tsv)

# Create app registration for Server app
serverApplicationId=$(az ad app create --display-name ${clusterName}Server --identifier-uris "https://${clusterName}Server" --query appId -o tsv)
az ad app update --id $serverApplicationId --set groupMembershipClaims=All
az ad sp create --id $serverApplicationId # Creating SP for app

serverApplicationSecret=$(az ad sp credential reset --name $serverApplicationId --credential-description "AKSPassword" --query password -o tsv)
az ad app permission add \
    --id $serverApplicationId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope 06da0dbc-49e2-44d2-8312-53f166ab848a=Scope 7ab1d382-f21e-4acd-a863-ba3e13f7da61=Role

az ad app permission grant --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000
az ad app permission admin-consent --id $serverApplicationId # This cannot be done via cloudshell, workaround is via portal

# Create app registration for Client app
clientApplicationId=$(az ad app create \
    --display-name "${clusterName}Client" \
    --native-app \
    --reply-urls "https://${clusterName}Client" \
    --query appId -o tsv)

az ad sp create --id $clientApplicationId

oAuthPermissionId=$(az ad app show --id $serverApplicationId --query "oauth2Permissions[0].id" -o tsv)

az ad app permission add --id $clientApplicationId --api $serverApplicationId --api-permissions $oAuthPermissionId=Scope
az ad app permission grant --id $clientApplicationId --api $serverApplicationId

# Get tenant ID
tenantId=$(az account show --query tenantId -o tsv)

# Create SP for AKS cluster and get SP id and password
SP=$(az ad sp create-for-rbac --skip-assignment -o json)
SP_ID=$(echo $SP | jq '.appId' | tr -d '"') # tr removes any quotations
SP_PASSWORD=$(echo $SP | jq '.password' | tr -d '"')

# Necessary because sometimes there is a delay
# in the creation of sp and its propogation
# issue referenced here: https://github.com/Azure/azure-cli/issues/1332
echo "Sleeping for 15s to allow for sp propogation"
sleep 15

# Assign subnet contributor permissions
az role assignment create --assignee $SP_ID --scope $SUBNET_ID --role Contributor

az aks create \
    --resource-group ohcontainer-rg \
    --name $clusterName \
    --generate-ssh-keys \
    --network-plugin azure \
    --vnet-subnet-id $SUBNET_ID \
    --docker-bridge-address 172.17.0.1/16 \
    --service-cidr 172.38.0.0/16 \
    --dns-service-ip 172.38.0.10 \
    --aad-server-app-id $serverApplicationId \
    --aad-server-app-secret $serverApplicationSecret \
    --aad-client-app-id $clientApplicationId \
    --aad-tenant-id $tenantId \
    --service-principal $SP_ID \
    --client-secret $SP_PASSWORD \
    --network-policy azure

az aks get-credentials --name $clusterName --resource-group teamResources --overwrite-existing --admin

AD_UPN=$(az ad signed-in-user show --query userPrincipalName -o tsv)
echo "User principal name for current user:" $AD_UPN