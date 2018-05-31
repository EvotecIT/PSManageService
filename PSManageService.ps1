


function PSGetService {
    [cmdletbinding()]
    param (
        $Computers,
        $Services
    )
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) { $Verbose = $true } else { $Verbose = $false }

    ### Define Runspace START
    $pool = [RunspaceFactory]::CreateRunspacePool(1, [int]$env:NUMBER_OF_PROCESSORS + 1)
    $pool.ApartmentState = "MTA"
    $pool.Open()
    $runspaces = @()
    ### Define Runspace END

    $AllStatus = @()
    foreach ($ServiceName in $Services) {
        foreach ($Computer in $Computers) {

            ### Script to RUN START
            $ScriptBlock = {
                Param (
                    [string]$Computer,
                    [string]$ServiceName,
                    [bool] $Verbose
                )
                if ($Verbose) {
                    $verbosepreference = 'continue'
                }
                $ServiceStatus = Get-Service -ComputerName $Computer -Name $ServiceName
                if ($ServiceStatus) {
                    #Add-Member -InputObject $ServiceStatus -MemberType NoteProperty -Name 'Computer' -Value $Computer -Force

                    $ServiceStatus = @{}
                    $ServiceStatus.Computer = $Computer
                    $ServiceStatus.Status = $ServiceStatus.Status
                    $ServiceStatus.Name = $ServiceStatus.Name
                    $ServiceStatus.DisplayName = $ServiceStatus.DisplayName
                } else {
                    $ServiceStatus = @{}
                    $ServiceStatus.Computer = $Computer
                    $ServiceStatus.Status = 'N/A'
                    $ServiceStatus.Name = $ServiceName
                    $ServiceStatus.DisplayName = ''
                }
                Write-Verbose "Get-Service - Processed $Computer with $ServiceName"
                return $ServiceStatus.ForEach( {[PSCustomObject]$_})
            }
            ### Script to RUN END

            # processing runspace start
            $runspace = [PowerShell]::Create()
            $null = $runspace.AddScript($ScriptBlock)
            $null = $runspace.AddParameter('Computer', $Computer)
            $null = $runspace.AddParameter('ServiceName', $ServiceName)
            $null = $runspace.AddParameter('Verbose', $Verbose)
            $runspace.RunspacePool = $pool
            $runspaces += [PSCustomObject]@{ Pipe = $runspace; Status = $runspace.BeginInvoke() }
            # processing runspace end

        }
    }

    ### End Runspaces START
    while ($runspaces.Status -ne $null) {
        $completed = $runspaces | Where-Object { $_.Status.IsCompleted -eq $true }
        foreach ($runspace in $completed) {
            foreach ($e in $($runspace.Pipe.Streams.Error)) {
                Write-Verbose "Get-Service - Error from runspace: $e"
            }
            foreach ($v in $($runspace.Pipe.Streams.Verbose)) {
                Write-Verbose "Get-Service - Verbose from runspace: $v"
            }
            $AllStatus += $runspace.Pipe.EndInvoke($runspace.Status)
            $runspace.Status = $null
        }
    }
    $pool.Close()
    $pool.Dispose()
    ### End Runspaces END

    # return Data
    return $AllStatus | Select-object Computer, Name, DisplayName, Status
}