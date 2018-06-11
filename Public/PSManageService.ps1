$sbGetService = {
    Param (
        [string]$Computer,
        [string]$ServiceName,
        [bool] $Verbose
    )
    $Measure = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
    if ($Verbose) { $verbosepreference = 'continue' }
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

function Get-PSService {
    [cmdletbinding()]
    param (
        $Computers,
        $Services,
        [int] $maxRunspaces = [int]$env:NUMBER_OF_PROCESSORS + 1
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
    $pool = New-Runspace -MaxRunspaces $maxRunspaces
    $runspaces = @()
    ### Define Runspace END

    foreach ($ServiceName in $Services) {
        foreach ($Computer in $Computers) {

            # processing runspace start
            $Parameters = @{
                Computer    = $Computer
                ServiceName = $ServiceName
                Verbose     = $Verbose
            }
            $runspaces += Start-Runspace -ScriptBlock $sbGetService -Parameters $Parameters -RunspacePool $pool
            # processing runspace end
        }
    }
    ### End Runspaces START
    $List = Stop-Runspace -Runspaces $runspaces -FunctionName 'Get-Service' -RunspacePool $pool
    ### End Runspaces END
    $MeasureTotal.Stop()
    Write-Verbose "Get-Service - Ending....$($measureTotal.Elapsed)"

    return $List
}
