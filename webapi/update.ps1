# update to stage
$m=(az network lb show -g dvpdemo-rg -n api-prod-vmss-lb --query "tags.ActiveSlot" -o tsv)
if ($m -eq "0") { $n="1" } else { $n="0" }
az vmss update -g dvpdemo-rg -n "api-prod-vmss-slot$n" --set "virtualMachineProfile.storageProfile.imageReference.id=/subscriptions/399042cf-e391-4471-9767-91f652d4ffc1/resourceGroups/test-vmss/providers/Microsoft.Compute/images/app221"

# vip swap
$m=(az network lb show -g dvpdemo-rg -n api-prod-vmss-lb --query "tags.ActiveSlot" -o tsv)
if ($m -eq "0") { $n="1" } else { $n="0" }
az network lb probe update -g dvpdemo-rg --lb-name api-prod-vmss-lb -n http-probe --set "requestPath='/api/ping?slot=slot$n'"
az network lb probe update -g dvpdemo-rg --lb-name api-prod-vmss-lb -n http-probe-stage --set "requestPath='/api/ping?slot=slot$m'"
az network lb update -g dvpdemo-rg -n api-prod-vmss-lb --set "tags.ActiveSlot=$n"