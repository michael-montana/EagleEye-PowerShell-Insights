Get-ChildItem -Path "examples" -Filter *.psm1 -Recurse | ForEach-Object {
    Import-Module $_.FullName
}

###############
##  Set Application Insights Variables
###############
Write-Host "Load Application Insights Modules"
$currentFunctionName = "ExampleUsage_Simple_MainRun.ps1"
$ENV:APPLICATIONINSIGHTS_CONNECTION_STRING = "InstrumentationKey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx;IngestionEndpoint=https://example-0.in.applicationinsights.azure.com/;LiveEndpoint=https://example.livediagnostics.monitor.azure.com/;ApplicationId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

###############
##  Load Application Insights Modules
###############
Write-Host "Load Application Insights Modules"
Get-ChildItem -Path "modules" -Filter *.psm1 -Recurse | ForEach-Object {
    Import-Module $_.FullName
}

###############
##  Initialize Application Insights Request Activity
###############
Write-Host "Initialize Application Insights Request Activity"
$AppInsRootRequestActivity = New-EEAppInsActivity -CloudRoleName $currentFunctionName -AppInsParentActivity $null -CloudRoleInstance $env:computername

###############
##  Verifying if dependencies services are available.
###############
Write-EELog "Verifying if dependencies services are available." -delimiterSize "large" -AppInsRequestActivity $AppInsRootRequestActivity

$dependentServices = @(
    "https://login.microsoftonline.com/common/oauth2/token",
    "https://login.microsoftonline.com/common/oauth2/v2.0/token",
    "https://graph.microsoft.com/v1.0"
)

foreach ($service in $dependentServices) {
    if (!(Confirm-EEDependencyEndpoint -Endpoint $service -AppInsParentActivity $AppInsRootRequestActivity)) {
        Write-EELog "Service $service is not available. Exiting script." -AppInsRequestActivity $AppInsRootRequestActivity
        exit 1
    }
    Write-EELog "Service $service is available. Continuing processing." -AppInsRequestActivity $AppInsRootRequestActivity
}


# Define some Public APIs to Call
$PublicAPIs = @(
    "https://prices.azure.com/api/retail/prices?`$filter=serviceName eq 'Virtual Machines'",
    "https://graph.microsoft.com",
    "https://planetarycomputer.microsoft.com/api/stac/v1",
    "https://login.microsoftonline.com"
)


###############
##
##  Call
##
###############

$Uri = "https://prices.azure.com/api/retail/prices?`$filter=serviceName eq 'Virtual Machines'"
$Method = "GET"
$Headers = @{}

Invoke-EERestMethod -Uri $Uri -Method $Method -Body $Body -Headers $Headers -AppInsParentActivity $AppInsRootRequestActivity > $null




###############
##
##  Subroutine Call
##
###############
Write-EELog "Call a Subroutine" -delimiterSize "large" -AppInsRequestActivity $AppInsRootRequestActivity

New-RecursiveSubRoutineCall -maxDepth 10 `
    -PublicAPIs $PublicAPIs `
    -AppInsParentActivity $AppInsRootRequestActivity


###############
##  Application Insights Telemetry
###############
Send-EEAppInsRequestLog -AppInsRequestActivity $AppInsRootRequestActivity