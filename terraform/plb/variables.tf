variable "admin_username" {
  default = "azureuser"
}

variable "admin_password" {
  default = "_add_here_"
}

variable "prefix" {
  default = "vmsstf"
}

variable "location" {
  default = "koreacentral"
}

variable "image_uri" {
    default = "_add_here_"
}

variable "vmss_name" {
    default = "api-prod-vmss"
}

variable "tag" {
    default = "test"
}

variable "vault_id" {
    default = "_add_here_"
}

variable "rgname" {
    default = "_add_here_"
}

variable "blob_uri" {
    default = "_add_here_"
}

variable "subnet_id" {
    default = "_add_here_"
}

variable "subnet_appgw_id" {
    default = "_add_here_"
}

variable "managedid_rgname" {
    default = "_add_here_"
}

variable "managedid_name" {
    default = "_add_here_"
}