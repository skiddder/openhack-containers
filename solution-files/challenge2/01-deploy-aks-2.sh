#!/bin/bash

# list available node sizes: 
#   --> az vm list-sizes --location westeurope -o table
# list available kubernetes versions:
#   --> az aks get-versions --location westeurope -o table
# reference of AKS ARM template can be found here: https://docs.microsoft.com/en-us/azure/templates/microsoft.containerservice/2020-12-01/managedclusters

RESOURCE_GROUP_NAME="ohcontainer-rg"
ARMTEMPLATE="./deploy-aks-3.json"
PARAMETERS="./deploy-aks-3.parameters.json"
DEPLOYMENT_NAME="aks-$(date -u +'%y-%m-%dT%H-%M-%S')"

az deployment group create --name $DEPLOYMENT_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --template-file "$ARMTEMPLATE" \
    --parameters "$PARAMETERS" \
    --verbose