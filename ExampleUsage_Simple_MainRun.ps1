$currentFunctionName = "ExampleUsage_Simple_MainRun.ps1"
$ENV:APPLICATIONINSIGHTS_CONNECTION_STRING = "InstrumentationKey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx;IngestionEndpoint=https://example-0.in.applicationinsights.azure.com/;LiveEndpoint=https://example.livediagnostics.monitor.azure.com/;ApplicationId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Import the modules in the modules folder and all subfolders
Get-ChildItem -Path "modules" -Filter *.psm1 -Recurse | ForEach-Object {
    Import-Module $_.FullName
}

###############
##
##  Initialize Application Insights Request Activity
##
###############
Write-Host "Initialize Application Insights Request Activity"

$AppInsRootRequestActivity = New-EEAppInsActivity -CloudRoleName $currentFunctionName -AppInsParentActivity $null -CloudRoleInstance $env:computername

###############
##
##  Verifying if dependencies services are available.
##
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

###############
##
##  Subroutine Call
##
###############
Write-EELog "Call a Subroutine" -delimiterSize "large" -AppInsRequestActivity $AppInsRootRequestActivity

New-SimpleSubRoutineCall -maxDepth 2 `
    -AppInsParentActivity $AppInsRootRequestActivity


###############
##  Application Insights Telemetry
###############
Send-EEAppInsRequestLog -AppInsRequestActivity $AppInsRootRequestActivity