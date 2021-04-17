#helm install --name prom --namespace monitoring -f 00-helm-prometheus-operator-values.yaml stable/prometheus-operator
helm install prom -f 00-helm-prometheus-operator-values.yaml stable/prometheus-operator --namespace monitoring 

## If you need to uninstall / clean install
# helm delete --purge monitoring-po
# kubectl delete crd prometheuses.monitoring.coreos.com
# kubectl delete crd prometheusrules.monitoring.coreos.com
# kubectl delete crd servicemonitors.monitoring.coreos.com
# kubectl delete crd podmonitors.monitoring.coreos.com
# kubectl delete crd alertmanagers.monitoring.coreos.com