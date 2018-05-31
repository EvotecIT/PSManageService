
Clear-Host
#Install-Module PSManageService
Import-Module PSManageService -Force

$Computers = 'AD2', 'AD1', 'AD1', 'EVO1', 'AD1', 'EVO1', 'EVO1', 'AD1', 'AD2', 'AD2'
$Services = 'WinRM', 'VSS'

# This is to show how long it takes for "standard" approach
#PSGetServiceNoRunspaces -Computers $Computers -Services $Services -Verbose | Format-Table -AutoSize

# This is the REAL speedup
PSGetService -Computers $Computers -Services $Services -Verbose | Format-Table -AutoSize