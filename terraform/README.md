# Terraform

4 types of sample provided
- Public LB
- Internal LB
- L7 LB (App G/W)
- Multi-nic

Note that only _Public LB_ sample revised with Terraform _AzureRM 3.22_. Other samples (appgw, internal LB) still use regacy AzureRM 2.1.

_Public LB_ sample also improved for security. That is, the script (iissetup.ps1) file which is located in a blob storage now download from private container instead of public container in a blob storage. see [this document](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows#property-managedidentity ) for more information.