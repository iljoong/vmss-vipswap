<#
 Setup Secondary NIC IP

 https://docs.microsoft.com/en-us/azure/virtual-machines/windows/multiple-nics#configure-guest-os-for-multiple-nics
#>

$ifidx = Get-NetIPConfiguration | where {$_.NetProfile.Name -eq "Unidentified network" -and  $_.InterfaceAlias -notmatch "vEthernet" } | % { echo $_.InterfaceIndex }
$ip = Get-NetIPConfiguration -InterfaceIndex $ifidx | % { echo $_.IPv4Address.IPAddress }
$gw = Get-NetIPConfiguration | where {$_.NetProfile.Name -eq "Network" } | % { echo $_.IPv4DefaultGateway.NextHop }
route add -p 0.0.0.0 MASK 0.0.0.0 $gw METRIC 5015 IF $ifidx
route add -p $ip MASK 255.255.255.0 $gw METRIC 5015 IF $ifidx