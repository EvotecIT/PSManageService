$Computers = 'AD1' #, 'AD2'
$Services = 'WinRM', 'VSS'

PSGetService -Computers $Computers -Services $Services -Verbose