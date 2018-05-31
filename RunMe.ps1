
Clear-Host
Import-Module PSManageService -Force

$Computers = 'AD2', 'AD1', 'AD1', 'EVO1', 'AD1', 'EVO1', 'EVO1', 'AD1', 'AD2', 'AD2'
$Services = 'WinRM', 'VSS'

PSGetServiceNoRunspaces -Computers $Computers -Services $Services -Verbose | Format-Table -AutoSize

PSGetService -Computers $Computers -Services $Services -Verbose | Format-Table -AutoSize
