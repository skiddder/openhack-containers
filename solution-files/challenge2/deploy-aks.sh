#!/bin/bash

# list available node sizes: 
#   --> az vm list-sizes --location westeurope -o table
# list available kubernetes versions:
#   --> az aks get-versions --location westeurope -o table
# reference of AKS ARM template can be found here: https://docs.microsoft.com/en-us/azure/templates/microsoft.containerservice/2020-12-01/managedclusters

LOCATION="westeurope"
RESOURCE_GROUP_NAME="oh-container-aks-rg"
AKS_NAME="ohcontainer"
DNS_PREFIX="ohcontainer"
NODE_SIZE="Standard_B2s"
NODE_COUNT=1
ARMTEMPLATE="./arm-aks.json"
KUBERNETES_VERSION="1.19.1"
VNET_ID="/subscriptions/48006515-4d68-4a94-84a2-69da5d351c6f/resourceGroups/oh-container-rg/providers/Microsoft.Network/virtualNetworks/ohcontainer-vnet"
NODE_SUBNET="nodes"
POD_SUBNET="pods"
SERVICE_CIDR="192.168.0.0/24"
BRIDGE_CIDR="172.17.0.1/16"
DNS_SERVICE_IP="192.168.0.10"

DEPLOYMENT_NAME="aks-$(date --iso-8601)"

az deployment group create --name $DEPLOYMENT_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --template-file "$ARMTEMPLATE" \
    --parameters aksClusterName=$AKS_NAME \
                dnsPrefix=$DNS_PREFIX \
                agentCount=$NODE_COUNT \
                agentVMSize=$NODE_SIZE \
                kubernetesVersion=$KUBERNETES_VERSION \
                vnetId=$VNET_ID \
                nodeSubnetName=$NODE_SUBNET \
                podSubnetName=$POD_SUBNET \
                serviceCIDR=$SERVICE_CIDR \
                dockerBridgeCIDR=$BRIDGE_CIDR \
                dnsServiceIP=$DNS_SERVICE_IP \
    --verbose