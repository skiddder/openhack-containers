#!/bin/bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prom -f ./00-helm-prometheus-operator-values.yml prometheus-community/kube-prometheus-stack --namespace monitoring