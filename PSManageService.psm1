function New-Runspace {
    param (
        [int] $minRunspaces = 1,
        [int] $maxRunspaces = [int]$env:NUMBER_OF_PROCESSORS + 1
    )
    $pool = [RunspaceFactory]::CreateRunspacePool($minRunspaces, $maxRunspaces)
    $pool.ApartmentState = "MTA"
    $pool.Open()
    return $pool
}
function Start-Runspace {
    param (
        $ScriptBlock,
        [hashtable] $Parameters,
        $pool
    )
    $runspace = [PowerShell]::Create()
    $null = $runspace.AddScript($ScriptBlock)
    $null = $runspace.AddParameters($Parameters)
    $runspace.RunspacePool = $pool
    return [PSCustomObject]@{ Pipe = $runspace; Status = $runspace.BeginInvoke() }
}

function Stop-Runspace {
    param(
        $Runspaces,
        $FunctionName,
        $Pool
    )
    $List = @()
    while ($Runspaces.Status -ne $null) {
        $completed = $runspaces | Where-Object { $_.Status.IsCompleted -eq $true }
        foreach ($runspace in $completed) {
            foreach ($e in $($runspace.Pipe.Streams.Error)) {
                Write-Verbose "$FunctionName - Error from runspace: $e"
            }
            foreach ($v in $($runspace.Pipe.Streams.Verbose)) {
                Write-Verbose "$FunctionName - Verbose from runspace: $v"
            }
            $List += $runspace.Pipe.EndInvoke($runspace.Status)
            $runspace.Status = $null
        }
    }
    $pool.Close()
    $pool.Dispose()
    return $List
}

function Get-PSService {
    [cmdletbinding()]
    param (
        $Computers,
        $Services
    )
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) { $Verbose = $true } else { $Verbose = $false }
    Write-Verbose 'Get-Service - Starting parallel processing....'

    $ComputersToProcess = ($Computers | Measure-Object).Count
    $ServicesToProcess = ($Services | Measure-Object).Count
    Write-Verbose -Message "Get-Service - Computers to process: $ComputersToProcess"
    Write-Verbose -Message "Get-Service - Computers List: $Computers"
    Write-Verbose -Message "Get-Service - Services to process: $ServicesToProcess"

    $MeasureTotal = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start

    ### Define Runspace START
    $pool = New-Runspace
    $runspaces = @()
    ### Define Runspace END


    foreach ($ServiceName in $Services) {
        foreach ($Computer in $Computers) {

            ### Script to RUN START
            $ScriptBlock = {
                Param (
                    [string]$Computer,
                    [string]$ServiceName,
                    [bool] $Verbose
                )

                $Measure = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
                if ($Verbose) {
                    $verbosepreference = 'continue'
                }
                Write-Verbose "Get-Service - [i] Processing $Computer with $ServiceName"
                $GetService = Get-Service -ComputerName $Computer -Name $ServiceName
                if ($GetService) {
                    $ServiceStatus = [ordered] @{}
                    $ServiceStatus.Computer = $Computer
                    $ServiceStatus.Status = $GetService.Status
                    $ServiceStatus.Name = $GetService.Name
                    $ServiceStatus.ServiceType = $GetService.ServiceType
                    $ServiceStatus.StartType = $GetService.StartType
                    $ServiceStatus.DisplayName = $GetService.DisplayName
                    $ServiceStatus.TimeProcessing = $Measure.Elapsed
                } else {
                    $ServiceStatus = [ordered]@{}
                    $ServiceStatus.Computer = $Computer
                    $ServiceStatus.Status = 'N/A'
                    $ServiceStatus.Name = $ServiceName
                    $ServiceStatus.ServiceType = 'N/A'
                    $ServiceStatus.StartType = 'N/A'
                    $ServiceStatus.DisplayName = 'N/A'
                    $ServiceStatus.TimeProcessing = $Measure.Elapsed
                }
                Write-Verbose "Get-Service - [i] Processed $Computer with $ServiceName - Time elapsed: $($Measure.Elapsed)"
                $Measure.Stop()
                return $ServiceStatus.ForEach( {[PSCustomObject]$_})
            }
            ### Script to RUN END

            # processing runspace start
            $Parameters = @{
                Computer    = $Computer
                ServiceName = $ServiceName
                Verbose     = $Verbose
            }
            $runspaces += Start-Runspace -ScriptBlock $ScriptBlock -Parameters $Parameters -pool $pool
            # processing runspace end

        }
    }
    ### End Runspaces START
    $List = Stop-Runspace -Runspaces $runspaces -FunctionName 'Get-Service' -Pool $pool
    ### End Runspaces END
    $MeasureTotal.Stop()
    Write-Verbose "Get-Service - Ending....$($measureTotal.Elapsed)"

    return $List
}

function Get-PSServiceNoRunspaces {
    [cmdletbinding()]
    param (
        $Computers,
        $Services
    )
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) { $Verbose = $true } else { $Verbose = $false }
    $AllStatus = @()
    Write-Verbose 'Get-Service - Starting standard processing....'
    $ComputersToProcess = ($Computers | Measure-Object).Count
    $ServicesToProcess = ($Services | Measure-Object).Count
    Write-Verbose -Message "Get-Service - Computers to process: $ComputersToProcess"
    Write-Verbose -Message "Get-Service - Computers List: $Computers"
    Write-Verbose -Message "Get-Service - Services to process: $ServicesToProcess"
    $MeasureTotal = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start

    $GetService = Get-Service -ComputerName $Computers -Name $Services
    # $GetService
    if ($GetService) {
        foreach ($Service in $GetService) {

            $ServiceStatus = [ordered] @{}
            $ServiceStatus.Computer = $Service.MachineName
            $ServiceStatus.Status = $Service.Status
            $ServiceStatus.Name = $Service.Name
            $ServiceStatus.ServiceType = $Service.ServiceType
            $ServiceStatus.StartType = $Service.StartType
            $ServiceStatus.DisplayName = $Service.DisplayName

            $AllStatus += $ServiceStatus
        }
    } else {
        $ServiceStatus = [ordered]@{}
        $ServiceStatus.Computer = $Computer
        $ServiceStatus.Status = 'N/A'
        $ServiceStatus.Name = $ServiceName
        $ServiceStatus.ServiceType = 'N/A'
        $ServiceStatus.StartType = 'N/A'
        $ServiceStatus.DisplayName = 'N/A'
        $AllStatus += $ServiceStatus
    }


    $MeasureTotal.Stop()
    Write-Verbose "Get-Service - Ending....$($measureTotal.Elapsed)"

    return $AllStatus.ForEach( {[PSCustomObject]$_})
}