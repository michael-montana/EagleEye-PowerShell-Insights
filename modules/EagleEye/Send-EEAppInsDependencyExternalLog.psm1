<#
.SYNOPSIS
This function sends a dependency log to Application Insights.

.DESCRIPTION
The Send-EEAppInsDependencyExternalLog function is used to send a dependency log to Application Insights. It takes in parameters for the AppInsRequestActivity and AppInsParentRequestActivity. It creates a new dependency telemetry object and sends it to Application Insights.

.PARAMETER AppInsRequestActivity
This parameter specifies the Application Insights Request Activity.

.PARAMETER AppInsParentRequestActivity
This parameter specifies the parent Application Insights Request Activity.

.EXAMPLE
Send-EEAppInsDependencyExternalLog -AppInsRequestActivity $AppInsRequestActivity -AppInsParentRequestActivity $AppInsParentRequestActivity

This example shows how to use the function to send a dependency log to Application Insights.

.NOTES
Author: Michael Montana
Email: michael_montana@outlook.com
#>
function Send-EEAppInsDependencyLog(){
    param(
        [Parameter(Mandatory=$true)]
        [object]$AppInsRequestActivity,
        [Parameter(Mandatory=$true)]
        [object]$AppInsParentRequestActivity
    )

    #Applicaiton Insights Client
    $applicationInsightsClient = $AppInsParentRequestActivity.AppInsClient

    #new System.Diagnostics.Activity("RequestActivity")
    $activity = New-Object System.Diagnostics.Activity("RequestActivity")
    $activity.Start()

    #Setup Telemetry
    #Set the RoleName
    $applicationInsightsClient.Context.Cloud.RoleName = $AppInsParentRequestActivity.CloudRoleName

    # Create a new dependency telemetry object
    $telemetry = New-Object -TypeName Microsoft.ApplicationInsights.DataContracts.DependencyTelemetry
    $telemetry.Id = $activity.spanId
    $telemetry.Name = "CALL $($AppInsRequestActivity.CloudRoleName) FROM $($AppInsParentRequestActivity.CloudRoleName)"
    $telemetry.Success = "True"
    $telemetry.Context.Operation.ParentId = $AppInsParentRequestActivity.Id
    $telemetry.Context.Operation.Id = $AppInsParentRequestActivity.OperationId

    #Stopwatch for Duration
    $lapTime = $AppInsParentRequestActivity.Stopwatch.Stop()
    $telemetry.Duration = [TimeSpan]::FromMilliseconds("$($lapTime.Elapsed.TotalMilliseconds)")
    
    # Track the telemetry
    $applicationInsightsClient.Track($telemetry)
    # Flush the telemetry to Application Insights
    $applicationInsightsClient.Flush()
}