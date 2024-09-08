function New-RecursiveSubRoutineCall (){

    param(
        [Parameter(Mandatory=$true)]
        [int]$maxDepth,
        [Parameter(Mandatory=$true)]
        [object]$PublicAPIs,
        [Parameter(Mandatory=$false)]
        [object]$AppInsParentActivity
    )
    
    # Generate a Function Name
    $FunctionName = "New-Call"
    $FunctionName += $maxDepth

    ###############
    ##  Application Insights Telemetry
    ###############
    $AppInsRequestActivity = New-EEAppInsDependency -AppInsParentActivity $AppInsParentActivity -CloudRoleName $FunctionName -CloudRoleInstance (New-GUID).Guid
    $ErrorActionPreference = "Stop"; trap {Send-EEAppInsExceptionLog -Exception $_ -AppInsRequestActivity $AppInsRequestActivity; return $null}

    # Sleep for x seconds (x is a random number between 1 and 5)
    $random = Get-Random -Minimum 1 -Maximum 5
    Write-EELog "Sleeping for $random seconds" -AppInsRequestActivity $AppInsRequestActivity
    Start-Sleep -Seconds $random

    #if maxDepth = 1 > set newMaxDepth to 0
    #if maxDepth = 2 > set newMaxDepth to 1
    #if maxDepth greater then 2, set newMaxDepth to a random number between 1 and maxDepth -1
    if ($maxDepth -eq 1) {
        $newMaxDepth = 0
    } elseif ($maxDepth -eq 2) {
        $newMaxDepth = 1
    } else {
        $newMaxDepth = Get-Random -Minimum 1 -Maximum ($maxDepth - 1)
    }

    # Call New-SimpleSubRoutineCall recursively until maxDepth is reached
    # if newMaxDepth is 0 then do nothing
    # if newMaxDepth is 1 then call New-RecursiveSubRoutineCall
    # if newMaxDepth is greater then 1 then call sequencally New-RecursiveSubRoutineCall in a number of rndom times between 1 and newMaxDepth
    if ($newMaxDepth -gt 0) {
        if ($newMaxDepth -eq 1) {
            New-RecursiveSubRoutineCall -maxDepth $newMaxDepth -PublicAPIs $PublicAPIs -AppInsParentActivity $AppInsRequestActivity
        } else {
            $rnd = Get-Random -Minimum 1 -Maximum $newMaxDepth
            for ($i = 0; $i -lt $rnd; $i++) {
                New-RecursiveSubRoutineCall -maxDepth $newMaxDepth -PublicAPIs $PublicAPIs -AppInsParentActivity $AppInsRequestActivity
            }
        }
    }

    # Pick a random Public API of the $PublicAPIs array and set it as $Uri
    $Uri = $PublicAPIs[(Get-Random -Minimum 0 -Maximum ($PublicAPIs.Count))]
    $Method = "GET"
    $Headers = @{}
    
    Invoke-EERestMethod -Uri $Uri -Method $Method -Body $Body -Headers $Headers -AppInsParentActivity $AppInsRequestActivity > $null
    

    ###############
    ##  Application Insights Telemetry
    ###############
    Send-EEAppInsRequestLog -AppInsRequestActivity $AppInsRequestActivity
}