#!/bin/bash
# Admin Consent does not work in Cloud shell! So make sure you either run this sceript locally and login properly using az cli
# or implement a user input to wait untill you grant admin consent manually to the server app

# the script is derived from the following docs page: https://docs.microsoft.com/en-us/azure/aks/azure-ad-integration-cli


# ----> execute this script in context of "account" tenant where you have global admin rights (or at least grant admin consent privileges)


# must be same as inaz-aks-create.sh:
aksname="ohcontainer2"


echo Create server app ...
# Create the Azure AD server component
# To integrate with AKS, you create and use an Azure AD application that acts as an endpoint for the identity requests. 
# The first Azure AD application you need gets Azure AD group membership for a user.
# basically, this enables kubectl
serverApplicationId=$(az ad app create \
    --display-name "${aksname}Server" \
    --identifier-uris "https://${aksname}Server" \
    --query appId -o tsv)

# Update the application group memebership claims
sleep 20

echo Update server app to get group membership claims ...
az ad app update --id $serverApplicationId --set groupMembershipClaims=All

# Create a service principal for the Azure AD application
echo Create SP for server app ...
az ad sp create --id $serverApplicationId

sleep 20

# Get the service principal secret
echo Create server app secret ...
serverApplicationSecret=$(az ad sp credential reset \
    --name $serverApplicationId \
    --credential-description "AKSPassword" \
    --query password -o tsv)

# api 00000003-0000-0000-c000-000000000000 is the Graph API
# requested permissions:
# - Read directory data
# - Sign in and read user profile
echo Define required permissions of the server app ...
az ad app permission add \
    --id $serverApplicationId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope 06da0dbc-49e2-44d2-8312-53f166ab848a=Scope 7ab1d382-f21e-4acd-a863-ba3e13f7da61=Role

sleep 20

echo Grant permissions to the server app ...
az ad app permission grant --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000

echo try admin consent server app... when you see a red errors, go to admin consent manually
echo Please note: Admin Consent does not work from Cloud Shell !!
az ad app permission admin-consent --id  $serverApplicationId

read -p 'Go to Azure Portal, grand admin consent to the server app and hit enter here ...' uservarS

# Create Azure AD client component
# The second Azure AD application is used when a user logs to the AKS cluster with the Kubernetes CLI (kubectl). 
# This client application takes the authentication request from the user and verifies credentials and permissions of the user against AAD
# this is required for RBAC
echo Create client app ...
clientApplicationId=$(az ad app create \
    --display-name "${aksname}Client" \
    --native-app \
    --reply-urls "https://${aksname}Client" \
    --query appId -o tsv)

echo Create SP client app ...
az ad sp create --id $clientApplicationId
sleep 20

oAuthPermissionId=$(az ad app show --id $serverApplicationId --query "oauth2Permissions[0].id" -o tsv)

# The client app needs permissions to perform the following actions:
# - client app needs permission to read server claims
echo add permissions grant to the client app
az ad app permission add --id $clientApplicationId --api $serverApplicationId --api-permissions $oAuthPermissionId=Scope

sleep 20
echo add permission grant to the client app
az ad app permission grant --id $clientApplicationId --api $serverApplicationId

echo "Please copy and paste/replace these parameters to az-aks-create.sh"
echo "aksname=\"$aksname\""
echo "serverApplicationId=\"$(az ad app list --query "[?displayName=='${aksname}Server'].appId" -o tsv)\""
echo "serverApplicationSecret=\"$(az ad sp credential reset --name $serverApplicationId --credential-description 'AKSPassword' --query password -o tsv)\""
echo "clientApplicationId=\"$(az ad app list --query "[?displayName=='${aksname}Client'].appId" -o tsv)\""