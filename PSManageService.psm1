


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
                Write-Verbose "Get-Service - [i] Processing $Computer with $ServiceName"
                $Measure = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
                if ($Verbose) {
                    $verbosepreference = 'continue'
                }
                $GetService = Get-Service -ComputerName $Computer -Name $ServiceName
                if ($GetService) {
                    #Add-Member -InputObject $ServiceStatus -MemberType NoteProperty -Name 'Computer' -Value $Computer -Force

                    $ServiceStatus = @{}
                    $ServiceStatus.Computer = $Computer
                    $ServiceStatus.Status = $GetService.Status
                    $ServiceStatus.Name = $GetService.Name
                    $ServiceStatus.DisplayName = $GetService.DisplayName
                    $ServiceStatus.TimeProcessing = $Measure.Elapsed
                } else {
                    $ServiceStatus = @{}
                    $ServiceStatus.Computer = $Computer
                    $ServiceStatus.Status = 'N/A'
                    $ServiceStatus.Name = $ServiceName
                    $ServiceStatus.DisplayName = 'N/A'
                    $ServiceStatus.TimeProcessing = $Measure.Elapsed
                }
                Write-Verbose "Get-Service - [i] Processed $Computer with $ServiceName"
                $Measure.Stop()
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
    return $AllStatus #| Select-object Computer, Name, DisplayName, Status
}