<#
.SYNOPSIS
This function sends a request log to Application Insights.

.DESCRIPTION
The Send-EEAppInsRequestLog function is used to send a request log to Application Insights. It takes in an optional parameter for the AppInsRequestActivity. If the AppInsRequestActivity is null or empty, the function returns null. Otherwise, it creates a new request telemetry object and sends it to Application Insights.

.PARAMETER AppInsRequestActivity
This parameter specifies the Application Insights Request Activity.

.EXAMPLE
Send-EEAppInsRequestLog -AppInsRequestActivity $AppInsRequestActivity

This example shows how to use the function to send a request log to Application Insights.

.NOTES
Author: Michael Montana
GitHub: https://github.com/michael-montana
#>
function Send-EEAppInsRequestLog(){
    param(
        [Parameter(Mandatory=$false)]
        [object]$AppInsRequestActivity
    )

    #Check if the AppInsRequestActivity is null or empty, if yes, then return null
    if([String]::IsNullOrEmpty($AppInsRequestActivity)){
        return $null
    }

    #Applicaiton Insights Client
    $applicationInsightsClient = $AppInsRequestActivity.TelemetryClient

    #Set the RoleName and Instance
    $applicationInsightsClient.Context.Cloud.RoleName = $AppInsRequestActivity.CloudRoleName
    $applicationInsightsClient.Context.Cloud.RoleInstance = $AppInsRequestActivity.CloudRoleInstance

    # Create a new request telemetry object
    $telemetry = New-Object -TypeName Microsoft.ApplicationInsights.DataContracts.RequestTelemetry
    $telemetry.Id = $AppInsRequestActivity.Id
    $telemetry.Name = "FUNC $($AppInsRequestActivity.CloudRoleName)"
    $telemetry.Success = "True"
    $telemetry.ResponseCode = "200"
    $telemetry.Context.Operation.ParentId = $AppInsRequestActivity.OperationParentId
    $telemetry.Context.Operation.Id = $AppInsRequestActivity.OperationId
    $telemetry.Context.Operation.Name = "FUNC $($AppInsRequestActivity.CloudRoleName)"
    
    #Stopwatch for Duration
    $AppInsRequestActivity.Stopwatch.Stop()
    $lapTime = $AppInsRequestActivity.Stopwatch

    $telemetry.Duration = [TimeSpan]::FromMilliseconds("$($lapTime.Elapsed.TotalMilliseconds)")

    # Track the telemetry
    $applicationInsightsClient.Track($telemetry)

    # Flush the telemetry to Application Insights
    $applicationInsightsClient.Flush()
}