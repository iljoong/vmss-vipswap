## VIP Swap with Application Gateway

VIP Swap Sample script for Application Gateway

![VIP Swap AppGW](./appgw-vipswap.png)

For implementation of VIP Swap with App Gateway, see this [doc](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-faq#how-do-i-do-a-vip-swap-for-virtual-machine-scale-sets-in-the-same-subscription-and-same-region)

### Update/Deploy Image

Script for deploy an image to stage slot

```
# get active backendpool/prod slot
$id = (az network application-gateway rule show -g $vmssrgname --gateway-name $appgwname -n $httprulename --query "backendAddressPool.id" -o tsv)
$m = $id.Split("/")[-1][-1] # get slot number only
if ($m -eq "0") { $n = "1" } else { $n = "0" }

# update stage slot
az vmss update -g $vmssrgname -n "api-prod-vmss-slot$n" --set "virtualMachineProfile.storageProfile.imageReference.id=/subscriptions/$subscription_id/resourceGroups/$rgname/providers/Microsoft.Compute/images/app$Build.BuildId"
```

### Swap Slot

Swap stage and production slot

> While App Gateway updates backend-pool, it may cause ~1 sec downtime.

```
# get current slot
$id = (az network application-gateway rule show -g $vmssrgname --gateway-name $appgwname -n $httprulename --query "backendAddressPool.id" -o tsv)
# "/subscriptions/.../resourceGroups/vmss/providers/Microsoft.Network/applicationGateways/appgw/backendAddressPools/slot0"
$m = $id.Split("/")[-1][-1] # get slot number only
if ($m -eq "0") { $n = "1" } else { $n = "0" }

# swap slot
az network application-gateway rule update -g $vmssrgname --gateway-name $appgwname -n $httprulename --address-pool "slot$n"
az network application-gateway rule update -g $vmssrgname --gateway-name $appgwname -n $httprulestagename --address-pool "slot$m"
```