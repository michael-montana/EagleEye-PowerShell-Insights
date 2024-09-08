<#
.SYNOPSIS
This function sends an exception log to Application Insights.

.DESCRIPTION
The Send-EEAppInsExceptionLog function is used to send an exception log to Application Insights. It takes in parameters for the Exception and AppInsRequestActivity. If the AppInsRequestActivity is null or empty, the function returns null. Otherwise, it creates a new exception telemetry object and sends it to Application Insights.

.PARAMETER Exception
This parameter specifies the exception to be logged.

.PARAMETER AppInsRequestActivity
This parameter specifies the Application Insights Request Activity.

.EXAMPLE
Send-EEAppInsExceptionLog -Exception $Exception -AppInsRequestActivity $AppInsRequestActivity

This example shows how to use the function to send an exception log to Application Insights.

.NOTES
Author: Michael Montana
Email: michael_montana@outlook.com
#>
function Send-EEAppInsExceptionLog(){
    param(
        [Parameter(Mandatory=$false)]
        $Exception,
        [Parameter(Mandatory=$false)]
        [object]$AppInsRequestActivity
    )

    Write-Host "Sending exception log to Application Insights..."

    #Check if the AppInsRequestActivity is null or empty, if yes, then return null
    if([String]::IsNullOrEmpty($AppInsRequestActivity)){
        Write-Host "AppInsRequestActivity is null or empty. Add it for more details about the exception."
        return $null
    }

    $applicationInsightsClient = $AppInsRequestActivity.TelemetryClient

    #Set the RoleName
    $applicationInsightsClient.Context.Cloud.RoleName = $AppInsRequestActivity.CloudRoleName
    $applicationInsightsClient.Context.Cloud.RoleInstance = $AppInsRequestActivity.CloudRoleInstance

    # Create a new trace telemetry object
    $telemetry = New-Object -TypeName Microsoft.ApplicationInsights.DataContracts.ExceptionTelemetry
    try {
        # Try to convert the error details to JSON (mostlikely it is then comming from a Invoke-RestMethod)
        #$errorDetails = $Exception.ErrorDetails.Message | ConvertFrom-Json -Depth 5 -ErrorAction Stop
        $telemetry.Message = $Exception.ErrorDetails.Message
    } catch {
        # Handle the error or ignore if the string is not a valid JSON
        $telemetry.Message = $Exception.Exception.Message.ToString()
    }
    foreach ($key in $Exception.Exception.AllKeys) {
        $telemetry.Properties[$key] = $Exception.Exception[$key]
    }
    $telemetry.Exception = $Exception.FullyQualifiedErrorId.toString()
    $telemetry.Context.Operation.Id = $AppInsRequestActivity.OperationId
    $telemetry.Context.Operation.ParentId = $AppInsRequestActivity.Id
    $applicationInsightsClient.TrackException($telemetry)
    
    # Flush the TelemetryClient to ensure the event is sent
    $applicationInsightsClient.Flush()

    # Write the exception to the log
    $logMessage = "Function: $($AppInsRequestActivity.CloudRoleName)`r`nInstance: $($AppInsRequestActivity.CloudRoleInstance)`r`nExceptionId: $($Exception.FullyQualifiedErrorId)`r`nMessage: $($Exception.Exception.Message)`r`nCodeline: $($Exception.InvocationInfo.Line.trim())"

    try {
        #$errorDetails = $Exception.ErrorDetails.Message | ConvertFrom-Json -ErrorAction Stop

        $logMessage += "`r`Details: $($Exception.ErrorDetails.Message)"
    } catch {
        # Handle the error or ignore if the string is not a valid JSON
        $logMessage += "`r`nDetails: $($Exception.Exception.Message.ToString())"
    }

    Write-EELog $logMessage -delimiterSize "exception" -AppInsRequestActivity $AppInsRequestActivity

}