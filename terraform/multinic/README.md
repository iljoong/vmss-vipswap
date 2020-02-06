# Other architecture: multi-nic VM 

## config

Set default gateway for secondary nic

> Note that _secondary nic_ is not fixed by interface index (#14 or #15). Use `Unidentified network` and !`vEthernet` to ge secondary NIC. Use _primary nic_ to get _Default Gateway_ info.

```
$ifidx = Get-NetIPConfiguration | where {$_.NetProfile.Name -eq "Unidentified network" -and  $_.InterfaceAlias -notmatch "vEthernet" } | % { echo $_.InterfaceIndex }
$ip = Get-NetIPConfiguration -InterfaceIndex $ifidx | % { echo $_.IPv4Address.IPAddress }
$gw = Get-NetIPConfiguration | where {$_.NetProfile.Name -eq "Network" } | % { echo $_.IPv4DefaultGateway.NextHop }
route add -p 0.0.0.0 MASK 0.0.0.0 $gw METRIC 5015 IF $ifidx
route add -p $ip MASK 255.255.255.0 $gw METRIC 5015 IF $ifidx
```

https://docs.microsoft.com/en-us/archive/blogs/bruce_adamczak/windows-2012-core-survival-guide-default-gateway-settings

Use following cli to get more information
```
Get-NetIPConfiguration | Format-table interfaceindex,interfacealias,ipv4address, @{ label="DefaultGateway"; Expression={ $_.IPv4DefaultGateway.NextHop }}, @{ label="DnsServers"; Expression={ $_.DnsServer.ServerAddresses}} -autosize
```

