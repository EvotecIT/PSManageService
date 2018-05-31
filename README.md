# PSManageService

Proof of concept for reading services (Get-Service -ComputerName <computer> -Name <service>) with runspaces.

1st is just a wrapper around Get-Service.

2nd is runspaces in action.

Th difference is 3minutes vs 42 seconds (for querying 10 servers for 2 services).

Where the 42 seconds is actually wait time for AD2 because AD2 is denying connectivity.

Since we ask AD2 x 3 times the 1st method takes over 3 minutes because it has to wait for termination before processing others.

Parallel version doesn't have to wait. It just waits in the end where all 3x AD2 terminate at similar time.