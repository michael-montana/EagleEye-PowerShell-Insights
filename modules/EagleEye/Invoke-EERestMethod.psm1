<#
.SYNOPSIS
This function invokes a REST method.

.DESCRIPTION
The Invoke-EERestMethod function is used to invoke a REST method. It takes in parameters such as Uri, Method, Headers, Body, and AppInsParentActivity. It also includes error handling and Application Insights Telemetry.

.PARAMETER Uri
The URI of the REST method.

.PARAMETER Method
The HTTP method to use (GET, POST, PUT, DELETE, etc.).

.PARAMETER Headers
The headers to include in the HTTP request.

.PARAMETER Body
The body of the HTTP request.

.PARAMETER AppInsParentActivity
Application Insights Telemetry.

.EXAMPLE
Invoke-EERestMethod -Uri 'https://api.example.com' -Method 'GET' -Headers @{'Authorization'='Bearer your-token'} -Body $body -AppInsParentActivity $AppInsParentActivity

.NOTES
Author: Michael Montana
GitHub: https://github.com/michael-montana
#>
function Invoke-EERestMethod(){
    param(
        [string]$Uri,
        [string]$Method,
        [hashtable]$Headers,
        [object]$Body,
        [object]$AppInsParentActivity
    )

    ###############
    ##  Application Insights Telemetry
    ###############
    $ErrorActionPreference = "Stop"; trap {Send-EEAppInsExceptionLog -Exception $_ -AppInsRequestActivity $AppInsParentActivity; return $null}

    # Set default Status to OK
    $status = "OK"
    
    # Craft Stopwatch
    $stopwatch = [System.Diagnostics.Stopwatch]::new()
    $stopwatch.Start()

    try {
        # Invoke the REST method
        $response = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method $Method -Body $Body -ErrorAction Stop
    }
    catch {
        # If the REST call fails, set the status to Error
        $exception = $_
        Send-EEAppInsExceptionLog -Exception $exception -AppInsRequestActivity $AppInsParentActivity; return $null
    }


    ###############
    ##  Application Insights Telemetry
    ###############

    # Stop the Stopwatch
    $stopwatch.Stop()

    # New Application Insights Telemetry Client
    $applicationInsightsClient = New-EEAppInsTelemetryClient
    $applicationInsightsClient.Context.Cloud.RoleName = $AppInsParentActivity.CloudRoleName
    $applicationInsightsClient.Context.Cloud.RoleInstance = $AppInsParentActivity.CloudRoleInstance

    # # Parse the Uri to separate the base URL and the query parameters
    $uriObject = New-Object -TypeName System.Uri -ArgumentList $Uri
    $telemetryUrl = New-Object -TypeName System.Uri -ArgumentList $uriObject.GetLeftPart([System.UriPartial]::Path)

    # Parse the query parameters from the Uri
    $queryParameters = [System.Web.HttpUtility]::ParseQueryString($uriObject.Query)

    # Track dependency 
    $activity = New-Object System.Diagnostics.Activity("RequestActivity")
    $activity.Start() | Out-Null
    $activity2 = New-Object System.Diagnostics.Activity("RequestActivity")
    $activity2.Start() | Out-Null
    $dependencyTelemetry = [Microsoft.ApplicationInsights.DataContracts.DependencyTelemetry]::new()
    $dependencyTelemetry.Name = $telemetryUrl.Host
    $dependencyTelemetry.Data = $telemetryUrl.AbsoluteUri
    $dependencyTelemetry.Duration = $stopwatch.Elapsed
    $dependencyTelemetry.Success = $status -eq "OK"
    $dependencyTelemetry.ResultCode = $status
    $dependencyTelemetry.Type = $telemetryUrl.Scheme
    $dependencyTelemetry.Target = $telemetryUrl.Host
    $dependencyTelemetry.Properties["Method"] = $Method
    $dependencyTelemetry.Properties["Headers"] = $Headers
    $dependencyTelemetry.Properties["Body"] = $Body
    $dependencyTelemetry.Id = $activity.spanId
    $dependencyTelemetry.Context.Operation.ParentId = $activity2.spanId
    $dependencyTelemetry.Context.Operation.Id = $AppInsParentActivity.OperationId
    foreach ($key in $queryParameters.AllKeys) {
        $dependencyTelemetry.Properties[$key] = $queryParameters[$key]
    }

    $applicationInsightsClient.TrackDependency($dependencyTelemetry)

    # Flush the TelemetryClient to ensure the event is sent
    $applicationInsightsClient.Flush()

    if($status -ne "OK"){
        throw $response
    }

    ###############
    ##  Application Insights Telemetry
    ###############
    # Not Applicable

    return $response
}