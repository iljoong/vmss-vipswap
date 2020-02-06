<#
 Setup IIS for 40080
#>

New-WebBinding -Name "Default Web Site" -Protocol http -Port 40080

netsh advfirewall firewall add rule name="Open Port 80" dir=in action=allow protocol=TCP localport=40080

<#
# Add SSL cert & HTTPS binding if you need

param (
    [string]$thumbprint
)

function logging($output)
{
    $time = Get-Date
    Write-Output "$time - $output" >> customscript.log
}

logging("enabling IIS SSL")
logging("--thumbprint: $thumbprint")
# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-secure-web-server#configure-iis-to-use-the-certificate
New-WebBinding -Name "Default Web Site" -Protocol https -Port 443

# Import-Module WebAdministration 
if (Test-Path IIS:\SslBindings\0.0.0.0!443) {Remove-Item -Path IIS:\SslBindings\0.0.0.0!443}
Get-ChildItem cert:\LocalMachine\My\$thumbprint | New-Item -Force -Path IIS:\SslBindings\!443

#>