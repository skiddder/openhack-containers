variable "subscription_id" {
    default = ""
    description = "Optional. if not specified current user context is used."
}

variable "tenant_id" {
    default = ""
    description = "Optional. if not specified current user context is used."
}

variable "location" {
  type = string
  default = "West Europe"
  description = "West Europe is AMS."
}

variable "customer" {
  type = string
  default = "ggg"
  description = "Currently lsg or ggg."
}

variable "env_name" {
    type = string
    default = "D"
    description = "D=develop, T=test or P=production."
}

variable "prefix" {
  type = string
  default = "forecast"
  description = "A prefix used for all resources"
}

variable "dns_prefix" {
  type = string
  default = "forecast"
  description = "A prefix used for aks cluster "
}

variable "network_configuration" {
  type = map(string)
  default = {
    "vnet_address_space"    = "192.168.0.0/16"
    "default_subnet_cidr"   = "192.168.1.64/26"
    "aks_nodes_subnet_cidr" = "192.168.3.0/24"
    "aks_lb_subnet_cidr"    = "192.168.2.0/26"   
    "fw_subnet_cidr"        = "192.168.1.0/26" 
  }
}
/*
variable "api_auth_ips" {
    description = "Whitelist of IP addresses that are allowed to access the AKS Master Control Plane API. I.e. you might want to put in your client's public ip address where you run kubectl."
    type        = list(string)
    default     = []
}
*/
variable "aks_sku" {
    default = "Free"
}

variable "aks_kubernetes_version" {
    default = "1.18.14"
}

variable "aks_admin_object_id" {
    default = ""
    description = "Provide id of an AAD group. Members of this group will have admin permissions (ClusterAdminRole) in your cluster."
}

variable "aks_configuration" {
  type = map(string)
  default = {
    "dns" = "15.0.0.0/20"
    "vm_user_name" = "ubuntu"
    "service_cidr" = "11.0.0.0/16"
    "dns_service_ip" = "11.0.0.10"
    "docker_bridge_cidr" = "172.17.0.1/16"
    "nodepool_1_vm_size" = "Standard_D2s_v3"
    "nodepool_1_size" = 3
    "nodepool_1_min" = 3
    "nodepool_1_max" = 10
    "nodepool_1_disk" = 500
  }
}
/*
variable "public_ssh_key_path" {
  description = "Public key path for SSH."
  default     = "~/.ssh/id_rsa.pub"
}
*/
variable "keyvault_id" {
  description   = "The URL of the keyvault where the database login secrets are stored."
  type          = string
  default       = "/subscriptions/4fe504a9-f5d1-4740-a5cf-532682d8fccf/resourceGroups/tst-kv-D-rg/providers/Microsoft.KeyVault/vaults/tst-kv-D"
}

variable "default_tags" {
  type = map

  default = {
    application = "paxforecast"
    business_unit = "GGG"
    department = "FRAEHI"
    environment = "develop"
    cost_center = "Y03551"
    owners = "alistair.forbes@lhind.dlh.de,heiko.rothenbach@lhind.dlh.de,marcelo.hofmann-machado@lhind.dlh.de"
    security_contact = "shengnan.xu.u554198@lhind.dlh.de"
  }
}
