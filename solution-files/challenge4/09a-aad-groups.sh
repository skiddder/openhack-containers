#!/bin/bash

# run script in account tenant (here nssimon.com)

## Web Dev
WEBDEV_GROUP_ID=$(az ad group create \
    --display-name Web-dev \
    --mail-nickname webdev \
    --query objectId -o tsv)

## Api Dev
APIDEV_GROUP_ID=$(az ad group create \
    --display-name Api-dev \
    --mail-nickname apidev \
    --query objectId -o tsv)

echo "WEBDEV_GROUP_ID=\"$WEBDEV_GROUP_ID\""
echo "APIDEV_GROUP_ID=\"$APIDEV_GROUP_ID\""
