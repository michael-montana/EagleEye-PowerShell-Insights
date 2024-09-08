<#
.SYNOPSIS
This function sends a dependency log to Application Insights.

.DESCRIPTION
The Send-EEAppInsDependencyLog function is used to send a dependency log to Application Insights. It takes in parameters for the CallerFunctionName, Success, DurationInMilliseconds, and AppInsDependencyActivity. It creates a new dependency telemetry object and sends it to Application Insights.

.PARAMETER CallerFunctionName
This parameter specifies the name of the caller function.

.PARAMETER Success
This parameter specifies whether the operation was successful.

.PARAMETER DurationInMilliseconds
This parameter specifies the duration of the operation in milliseconds.

.PARAMETER AppInsDependencyActivity
This parameter specifies the Application Insights Dependency Activity.

.EXAMPLE
Send-EEAppInsDependencyLog -CallerFunctionName "FunctionName" -Success "True" -DurationInMilliseconds "1000" -AppInsDependencyActivity $AppInsDependencyActivity

This example shows how to use the function to send a dependency log to Application Insights.

.NOTES
Author: Michael Montana
GitHub: https://github.com/michael-montana
#>
function Send-EEAppInsDependencyLog(){
    param(
        [Parameter(Mandatory=$true)]
        [string]$CallerFunctionName,
        [Parameter(Mandatory=$true)]
        [string]$Success,
        [Parameter(Mandatory=$true)]
        [string]$DurationInMilliseconds,
        [Parameter(Mandatory=$true)]
        [object]$AppInsDependencyActivity
    )

    #Applicaiton Insights Client
    $applicationInsightsClient = $AppInsDependencyActivity.TelemetryClient

    #Setup Telemetry
    #Set the RoleName
    $applicationInsightsClient.Context.Cloud.RoleName = $CallerFunctionName
    $applicationInsightsClient.Context.Cloud.RoleInstance = $AppInsDependencyActivity.CloudRoleInstance

    # Create a new dependency telemetry object
    $telemetry = New-Object -TypeName Microsoft.ApplicationInsights.DataContracts.DependencyTelemetry
    $telemetry.Id = $AppInsDependencyActivity.Id
    $telemetry.Name = "CALL $($AppInsDependencyActivity.CloudRoleName) FROM $($CallerFunctionName)"
    $telemetry.Success = $Success
    $telemetry.Context.Operation.ParentId = $AppInsDependencyActivity.OperationParentId
    $telemetry.Context.Operation.Id = $AppInsDependencyActivity.OperationId
    $telemetry.Duration = [TimeSpan]::FromMilliseconds("$DurationInMilliseconds")
    
    # Track the telemetry
    $applicationInsightsClient.Track($telemetry)
    # Flush the telemetry to Application Insights
    $applicationInsightsClient.Flush()
}