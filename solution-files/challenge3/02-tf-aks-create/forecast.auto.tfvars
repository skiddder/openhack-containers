customer                = "tst"
env_name                = "D"
prefix                  = "4cast"
dns_prefix              = "4cast"
# api_auth_ips            = ["95.222.26.147"] # public ip of client where kubectl is executed 
# also ensure all required outbound ports are allowed on your firewall: https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic
keyvault_id             = "/subscriptions/4fe504a9-f5d1-4740-a5cf-532682d8fccf/resourceGroups/tst-kv-D-rg/providers/Microsoft.KeyVault/vaults/tst-kv-D"
aks_admin_object_id     = "070ec11b-e851-4982-afa6-75b8f94eda78" # provide id of an AAD group you are member in