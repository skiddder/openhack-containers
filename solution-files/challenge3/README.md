# Challenge 3 Solution

## Configure and deploy the AKS cluster

Run `cluster-config.sh`
> NOTE: Make sure you change `addressPrefix` to an appropriate address space. It should be an address space within your vnet address space that does not overlap with any other subnet's address space.

## Create RBAC binding

1. The `cluster-config` script will print out the user principal name for the current user after creating the AKS cluster. Copy and paste this value into `basic-azure-ad-binding.yaml`.

2. Create your `ClusterRoleBinding`

```bash
kubectl apply -f basic-azure-ad-binding.yaml
```

## Access cluster with AAD

```bash
# Overwrite your AKS admin credentials
az aks get-credentials --resource-group teamResources --name myAKSCluster --overwrite-existing

# View pods across all namespaces. You should be prompted to login.
kubectl get pods --all-namespaces
```
