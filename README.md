# PSManageService

Proof of concept for reading services (Get-Service -ComputerName <computer> -Name <service>) with runspaces.

1st is just a wrapper around Get-Service.

2nd is runspaces in action.

Th difference is 3minutes vs 42 seconds (for querying 10 servers for 2 services).

Where the 42 seconds is actually wait time for AD2 because AD2 is denying connectivity.

Since we ask AD2 x 3 times the 1st method takes over 3 minutes because it has to wait for termination before processing others.

Parallel version doesn't have to wait. It just waits in the end where all 3x AD2 terminate at similar time.

```

VERBOSE: Get-Service - Starting standard processing....
VERBOSE: Get-Service - Computers to process: 10
VERBOSE: Get-Service - Computers List: AD2 AD1 AD1 EVO1 AD1 EVO1 EVO1 AD1 AD2 AD2
VERBOSE: Get-Service - Services to process: 2
VERBOSE: Get-Service - Ending....00:03:09.0969836

Computer  Status Name        ServiceType StartType DisplayName
--------  ------ ----        ----------- --------- -----------
AD1      Running VSS     Win32OwnProcess    Manual Volume Shadow Copy
EVO1     Stopped VSS     Win32OwnProcess    Manual Volume Shadow Copy
AD1      Running WinRM Win32ShareProcess Automatic Windows Remote Management (WS-Management)
EVO1     Stopped WinRM Win32ShareProcess    Manual Windows Remote Management (WS-Management)


VERBOSE: Get-Service - Starting parallel processing....
VERBOSE: Get-Service - Computers to process: 10
VERBOSE: Get-Service - Computers List: AD2 AD1 AD1 EVO1 AD1 EVO1 EVO1 AD1 AD2 AD2
VERBOSE: Get-Service - Services to process: 2
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with WinRM - Time elapsed: 00:00:00.0123568
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with WinRM - Time elapsed: 00:00:00.0065619
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with WinRM - Time elapsed: 00:00:00.0018587
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with WinRM - Time elapsed: 00:00:00.0090690
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with WinRM - Time elapsed: 00:00:00.0018523
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with WinRM - Time elapsed: 00:00:00.0023962
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with WinRM - Time elapsed: 00:00:00.0067552
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with VSS - Time elapsed: 00:00:00.0080459
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with VSS - Time elapsed: 00:00:00.0024858
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with VSS - Time elapsed: 00:00:00.0075792
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with VSS - Time elapsed: 00:00:00.0081157
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with VSS - Time elapsed: 00:00:00.0020295
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with VSS - Time elapsed: 00:00:00.0020629
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with VSS - Time elapsed: 00:00:00.0091502
VERBOSE: Get-Service - Error from runspace: Cannot find any service with service name 'VSS'.
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD2 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD2 with VSS - Time elapsed: 00:00:41.8883808
VERBOSE: Get-Service - Error from runspace: Cannot find any service with service name 'VSS'.
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD2 with VSS
VERBOSE: Get-Service - Starting parallel processing....
VERBOSE: Get-Service - Computers to process: 10
VERBOSE: Get-Service - Computers List: AD2 AD1 AD1 EVO1 AD1 EVO1 EVO1 AD1 AD2 AD2
VERBOSE: Get-Service - Services to process: 2
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with WinRM - Time elapsed: 00:00:00.0245295
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with WinRM - Time elapsed: 00:00:00.0094422
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with WinRM - Time elapsed: 00:00:00.0024024
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with WinRM - Time elapsed: 00:00:00.0105087
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with WinRM - Time elapsed: 00:00:00.0033931
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with WinRM - Time elapsed: 00:00:00.0054566
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with WinRM - Time elapsed: 00:00:00.0098258
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with VSS - Time elapsed: 00:00:00.0105928
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with VSS - Time elapsed: 00:00:00.0018225
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with VSS - Time elapsed: 00:00:00.0087472
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with VSS - Time elapsed: 00:00:00.0073372
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with VSSVERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with VSS - Time elapsed: 00:00:00.0019791
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing EVO1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed EVO1 with VSS - Time elapsed: 00:00:00.0018405
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD1 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD1 with VSS - Time elapsed: 00:00:00.0071055
VERBOSE: Get-Service - Error from runspace: Cannot find any service with service name 'WinRM'.
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD2 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD2 with WinRM - Time elapsed: 00:00:42.0072780
VERBOSE: Get-Service - Error from runspace: Cannot find any service with service name 'VSS'.
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD2 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD2 with VSS - Time elapsed: 00:00:41.8996969
VERBOSE: Get-Service - Error from runspace: Cannot find any service with service name 'WinRM'.
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD2 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD2 with WinRM - Time elapsed: 00:00:41.8898299
VERBOSE: Get-Service - Error from runspace: Cannot find any service with service name 'WinRM'.
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD2 with WinRM
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD2 with WinRM - Time elapsed: 00:00:41.8919353
VERBOSE: Get-Service - Error from runspace: Cannot find any service with service name 'VSS'.
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD2 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD2 with VSS - Time elapsed: 00:00:41.8535059
VERBOSE: Get-Service - Error from runspace: Cannot find any service with service name 'VSS'.
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processing AD2 with VSS
VERBOSE: Get-Service - Verbose from runspace: Get-Service - [i] Processed AD2 with VSS - Time elapsed: 00:00:41.8439419
VERBOSE: Get-Service - Ending....00:00:42.0700419

Computer  Status Name        ServiceType StartType DisplayName                               TimeProcessing
--------  ------ ----        ----------- --------- -----------                               --------------
AD1      Running WinRM Win32ShareProcess Automatic Windows Remote Management (WS-Management) 00:00:00.0244221
AD1      Running WinRM Win32ShareProcess Automatic Windows Remote Management (WS-Management) 00:00:00.0094132
EVO1     Stopped WinRM Win32ShareProcess    Manual Windows Remote Management (WS-Management) 00:00:00.0023737
AD1      Running WinRM Win32ShareProcess Automatic Windows Remote Management (WS-Management) 00:00:00.0104825
EVO1     Stopped WinRM Win32ShareProcess    Manual Windows Remote Management (WS-Management) 00:00:00.0033665
EVO1     Stopped WinRM Win32ShareProcess    Manual Windows Remote Management (WS-Management) 00:00:00.0054218
AD1      Running WinRM Win32ShareProcess Automatic Windows Remote Management (WS-Management) 00:00:00.0097657
AD1      Running VSS     Win32OwnProcess    Manual Volume Shadow Copy                        00:00:00.0104993
EVO1     Stopped VSS     Win32OwnProcess    Manual Volume Shadow Copy                        00:00:00.0018034
AD1      Running VSS     Win32OwnProcess    Manual Volume Shadow Copy                        00:00:00.0087123
AD1      Running VSS     Win32OwnProcess    Manual Volume Shadow Copy                        00:00:00.0073114
EVO1     Stopped VSS     Win32OwnProcess    Manual Volume Shadow Copy                        00:00:00.0019573
EVO1     Stopped VSS     Win32OwnProcess    Manual Volume Shadow Copy                        00:00:00.0018231
AD1      Running VSS     Win32OwnProcess    Manual Volume Shadow Copy                        00:00:00.0070830
AD2          N/A WinRM               N/A       N/A N/A                                       00:00:42.0072574
AD2          N/A VSS                 N/A       N/A N/A                                       00:00:41.8996828
AD2          N/A WinRM               N/A       N/A N/A                                       00:00:41.8898159
AD2          N/A WinRM               N/A       N/A N/A                                       00:00:41.8919224
AD2          N/A VSS                 N/A       N/A N/A                                       00:00:41.8534920
AD2          N/A VSS                 N/A       N/A N/A                                       00:00:41.8439273

```