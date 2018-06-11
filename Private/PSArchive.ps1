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