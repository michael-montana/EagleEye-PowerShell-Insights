function New-ComplexSubRoutineCall4 (){

    param(
        [Parameter(Mandatory=$true)]
        [int]$maxDepth,
        [Parameter(Mandatory=$false)]
        [object]$AppInsParentActivity
    )
    
    ###############
    ##  Application Insights Telemetry
    ###############
    $AppInsRequestActivity = New-EEAppInsDependency -AppInsParentActivity $AppInsParentActivity -CloudRoleName $MyInvocation.MyCommand.Name
    $ErrorActionPreference = "Stop"; trap {Send-EEAppInsExceptionLog -Exception $_ -AppInsRequestActivity $AppInsRequestActivity; return $null}


    # Sleep for x seconds (x is a random number between 1 and 5)
    $random = Get-Random -Minimum 1 -Maximum 5
    Write-EELog "Sleeping for $random seconds" -AppInsRequestActivity $AppInsRequestActivity
    Start-Sleep -Seconds $random

    # Call New-ComplexSubRoutineCall recursively until maxDepth is reached
    if ($maxDepth -gt 0) {
        New-ComplexSubRoutineCall4 -maxDepth ($maxDepth - 1) -AppInsParentActivity $AppInsRequestActivity
    }

    $Uri = "https://prices.azure.com/api/retail/prices?`$filter=serviceName eq 'Virtual Machines'"
    $Method = "GET"
    $Headers = @{}
    
    Invoke-EERestMethod -Uri $Uri -Method $Method -Body $Body -Headers $Headers -AppInsParentActivity $AppInsRequestActivity
    

    ###############
    ##  Application Insights Telemetry
    ###############
    Send-EEAppInsRequestLog -AppInsRequestActivity $AppInsRequestActivity
}