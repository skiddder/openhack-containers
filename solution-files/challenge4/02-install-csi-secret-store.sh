#!/bin/bash

helm repo add csi-secrets-store-provider-azure https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts
helm install csi-secrets-store-provider-azure/csi-secrets-store-provider-azure --generate-name