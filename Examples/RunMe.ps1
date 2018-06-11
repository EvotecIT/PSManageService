
Clear-Host
#Install-Module PSManageService
Import-Module PSManageService -Force
$Computers = 'AD1'
#$Computers = 'AD2', 'AD1', 'AD1', 'EVO1', 'AD1', 'EVO1', 'EVO1', 'AD1', 'AD2', 'AD2'
$Services = 'WinRM', 'VSS'

# This is to show how long it takes for "standard" approach
#Get-PSServiceNoRunspaces -Computers $Computers -Services $Services -Verbose | Format-Table -AutoSize

# This is the REAL speedup
Get-PSService -Computers $Computers -Services $Services -Verbose | Format-Table -AutoSize

#Get-CimInstance -ClassName Win32_Service -Filter 'DisplayName = "WinRM" OR DisplayName = "VSS"' -ComputerName $Computers