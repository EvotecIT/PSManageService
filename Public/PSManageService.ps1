$sbGetService = {
    Param (
        [string]$Computer,
        [string]$ServiceName,
        [bool] $Verbose
    )
    $Measure = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
    if ($Verbose) { $verbosepreference = 'continue' }

    if ($ServiceName -eq '') {
        Write-Verbose "Get-Service - [i] Processing $Computer for all services"
        $GetServices = Get-Service -ComputerName $Computer
    } else {
        Write-Verbose "Get-Service - [i] Processing $Computer with $ServiceName"
        $GetServices = Get-Service -ComputerName $Computer -Name $ServiceName
    }
    $ServiceList = @()
    foreach ($GetService in $GetServices) {

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
        $ServiceList += $ServiceStatus
    }
    Write-Verbose "Get-Service - [i] Processed $Computer with $ServiceName - Time elapsed: $($Measure.Elapsed)"
    $Measure.Stop()
    return $ServiceList.ForEach( {[PSCustomObject]$_})
}

function Get-PSService {
    [cmdletbinding()]
    param (
        [string[]] $Computers = $Env:COMPUTERNAME,
        [string[]] $Services,
        [int] $MaxRunspaces = [int]$env:NUMBER_OF_PROCESSORS + 1
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
    $runspaces = @()
    $pool = New-Runspace -MaxRunspaces $maxRunspaces
    ### Define Runspace END


    foreach ($Computer in $Computers) {
        if ($Services -ne $null) {
            foreach ($ServiceName in $Services) {
                Write-Verbose "Get-Service - Getting service $ServiceName on $Computer"
                # processing runspace start
                $Parameters = @{
                    Computer    = $Computer
                    ServiceName = $ServiceName
                    Verbose     = $Verbose
                }
                $runspaces += Start-Runspace -ScriptBlock $sbGetService -Parameters $Parameters -RunspacePool $pool
                # processing runspace end
            }
        } else {
            Write-Verbose "Get-Service - Getting all services on $Computer"
            $Parameters = @{
                Computer    = $Computer
                ServiceName = ''
                Verbose     = $Verbose
            }
            $runspaces += Start-Runspace -ScriptBlock $sbGetService -Parameters $Parameters -RunspacePool $pool
        }
    }
    ### End Runspaces START
    $List = Stop-Runspace -Runspaces $runspaces -FunctionName 'Get-Service' -RunspacePool $pool
    ### End Runspaces END
    $MeasureTotal.Stop()
    Write-Verbose "Get-Service - Ending....$($measureTotal.Elapsed)"

    return $List
}
