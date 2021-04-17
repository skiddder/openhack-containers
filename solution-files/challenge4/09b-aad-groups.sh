#!/bin/bash

# run script in resource tenant where AKS cluster is deployed to
# copy WEBDEV_GROUP_ID and APIDEV_GROUP_ID from script 09a here:
WEBDEV_GROUP_ID="844a01b1-5d6e-424c-9716-9a347d977565"
APIDEV_GROUP_ID="c03eff94-250a-4d29-a40f-667ba8c2b9da"

AKS_ID="/subscriptions/4fe504a9-f5d1-4740-a5cf-532682d8fccf/resourcegroups/ohcontainer-rg/providers/Microsoft.ContainerService/managedClusters/ohcontainer2"

## Web Dev
az role assignment create \
    --assignee $WEBDEV_GROUP_ID \
    --role "Azure Kubernetes Service Cluster User Role" \
    --scope $AKS_ID

## Api Dev
az role assignment create \
    --assignee $APIDEV_GROUP_ID \
    --role "Azure Kubernetes Service Cluster User Role" \
    --scope $AKS_ID
