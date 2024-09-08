<#
.SYNOPSIS
This function confirms the availability of a dependency endpoint and logs the result to Application Insights.

.DESCRIPTION
The Confirm-EEDependencyEndpoint function is used to confirm the availability of a dependency endpoint. It takes in parameters for the Endpoint and AppInsParentActivity. It creates a new Application Insights Telemetry Client, calls the REST API, tracks the dependency, and flushes the TelemetryClient to ensure the event is sent.

.PARAMETER Endpoint
This parameter specifies the endpoint to be checked.

.PARAMETER AppInsParentActivity
This parameter specifies the parent Application Insights activity.

.EXAMPLE
Confirm-EEDependencyEndpoint -Endpoint "http://example.com" -AppInsParentActivity $AppInsParentActivity

This example shows how to use the function to confirm the availability of a dependency endpoint and log the result to Application Insights.

.NOTES
Author: Michael Montana
GitHub: https://github.com/michael-montana
#>
function Confirm-EEDependencyEndpoint {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Endpoint,
        [object]$AppInsParentActivity
    )

    # New Application Insights Telemetry Client
    $applicationInsightsClient = New-EEAppInsTelemetryClient
    $applicationInsightsClient.Context.Cloud.RoleName = $AppInsParentActivity.CloudRoleName
    $applicationInsightsClient.Context.Cloud.RoleInstance = $AppInsParentActivity.CloudRoleInstance

    # Call the REST API
    $apiUrl = $Endpoint
    $startTime = [DateTime]::UtcNow
    $response = Invoke-WebRequest -Uri $apiUrl
    $endTime = [DateTime]::UtcNow

    # Track the dependency
    $telemetry = New-Object -TypeName Microsoft.ApplicationInsights.DataContracts.AvailabilityTelemetry
    $telemetry.Id = $AppInsParentActivity.Id
    $telemetry.Name = "API Call: $Endpoint"
    $telemetry.RunLocation = "SwitzerlandNorth"
    $telemetry.Duration = $endTime - $startTime
    $telemetry.Success = $response.StatusCode -eq 200
    $telemetry.Context.Operation.Id = $AppInsParentActivity.OperationId
    $telemetry.Context.Operation.ParentId = $AppInsParentActivity.OperationParentId
    $telemetry.Context.Operation.Name = "Availability: $Endpoint"
    $applicationInsightsClient.TrackAvailability($telemetry)

    # Flush the TelemetryClient to ensure the event is sent
    $applicationInsightsClient.Flush()

    if ($telemetry.Success -eq $false) {
        return $false
    }

    return $telemetry.Success
}