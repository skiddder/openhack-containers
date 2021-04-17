#!/bin/bash
# instructions:
# first create apps and service principals for RBAC. This will be achieved by executing script az-app-create.sh
# then run this script (az-aks-create.sh) to create a service principal scoped for the target subscription and create AKS

# Note: Admin Consent does not work in Cloud shell! So make sure you either run this sceript locally and login properly using az cli
# or implement a user input to wait untill you grant admin consent manually to the server app

# !! Attention !! if you do not have permission to give admin consent in the target tenant, create server-app and client-app in another tenant where you
# have admin consent permission. In this case you need to execute the script az-app-create.sh in the context of the other tenant
# all users you want to grant RBAC permissions/roles to must origin from that other tenant then. Guest users will work. In the rbac-binding.yaml file
# you need to use the user's objectId in that other tenant in this case. 

# the sh scripts are derived from the following docs page: https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration-cli

# ----> execute this script within the context of the subscription/tenant where the AKS cluster will be hosted in

# will be created:
dockerBridgeAddress="172.17.0.1/16"
dnsServiceIp="172.38.0.10" 
serviceCidr="172.38.0.0/16"

# must exist before execution (deployment targets):
tenantId="d8db7684-e2ab-4555-8393-7bdc8ad9b302" # nssimon.onmicrosoft.com --> must be the tenant where server-app and client-app were created
subscriptionId="4fe504a9-f5d1-4740-a5cf-532682d8fccf" # nslz-landingzone 
targetResourceGroup="ohcontainer-rg"

targetSubnetId="/subscriptions/${subscriptionId}/resourceGroups/${targetResourceGroup}/providers/Microsoft.Network/virtualNetworks/vnet/subnets/aks2"
attachedACR="registryvnb0999" # just provide the name - not FQDN

# copy from results of az-app-create.sh:
aksname="ohcontainer2"
serverApplicationId="6dff4c6b-5f7c-48cb-9d5c-946f19136eee"
serverApplicationSecret="ZL8fYCf6MS29YdkZQygGy1lHFmwV_OrAQa"
clientApplicationId="8b7396a6-7d98-4c06-8b91-2f9643068b4e"

# service principal (must be in same AAD as your AKS cluster's subscription)
# when fetching aks-credentials, use your admin account from the tenant where your AKS cluster is located
SERVICE_PRINCIPAL_ID=$(az ad sp create-for-rbac --role="Contributor" \
    --scopes="/subscriptions/${subscriptionId}/resourceGroups/$targetResourceGroup" \
    --name "${aksname}_sp" \
    --query appId -o tsv)

SERVICE_PRINCIPAL_SECRET=$(az ad sp credential reset \
    --name $SERVICE_PRINCIPAL_ID \
    --credential-description "AKSPassword" \
    --query password -o tsv)

sleep 20

az aks create \
    --resource-group $targetResourceGroup \
    --name $aksname \
    --network-plugin azure \
    --vnet-subnet-id $targetSubnetId \
    --docker-bridge-address $dockerBridgeAddress \
    --dns-service-ip $dnsServiceIp \
    --service-cidr $serviceCidr \
    --generate-ssh-keys \
    --node-count 3 \
    --attach-acr $attachedACR \
    --enable-rbac \
    --aad-server-app-id $serverApplicationId \
    --aad-server-app-secret $serverApplicationSecret \
    --aad-client-app-id $clientApplicationId \
    --aad-tenant-id $tenantId \
    --enable-addons monitoring \
    --network-policy azure \
    --client-secret $SERVICE_PRINCIPAL_SECRET \
    --service-principal $SERVICE_PRINCIPAL_ID
    

echo Do not forget to install flexvol to the cluster: kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml