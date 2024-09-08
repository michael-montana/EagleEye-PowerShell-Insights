<#
.SYNOPSIS
This function sends a dependency log to Application Insights.

.DESCRIPTION
The New-EEAppInsTelemetryClient function is used to send a dependency log to Application Insights. It takes in parameters for the AppInsRequestActivity and AppInsParentRequestActivity. It creates a new dependency telemetry object and sends it to Application Insights.

.PARAMETER AppInsRequestActivity
This parameter specifies the Application Insights Request Activity.

.PARAMETER AppInsParentRequestActivity
This parameter specifies the parent Application Insights Request Activity.

.EXAMPLE
New-EEAppInsTelemetryClient -AppInsRequestActivity $AppInsRequestActivity -AppInsParentRequestActivity $AppInsParentRequestActivity

This example shows how to use the function to send a dependency log to Application Insights.

.NOTES
Author: Michael Montana
Email: michael_montana@outlook.com
#>
function New-EEAppInsTelemetryClient (){
    
    # determine if the environment is running in an Azure Function app or locally wih Azure Function App Core Tools in an Console, where $ENV:APPLICATIONINSIGHTS_CONNECTION_STRING is not available
    # if running locally, the $ENV:APPLICATIONINSIGHTS_CONNECTION_STRING is not available
    if ($null -eq $ENV:APPLICATIONINSIGHTS_CONNECTION_STRING) {
        
        # set the $ENV:APPLICATIONINSIGHTS_CONNECTION_STRING to the InstrumentationKey of the Application Insights resource
        $ENV:APPLICATIONINSIGHTS_CONNECTION_STRING = "InstrumentationKey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx;IngestionEndpoint=https://example-0.in.applicationinsights.azure.com/;LiveEndpoint=https://example.livediagnostics.monitor.azure.com/;ApplicationId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

    }

    $applicationInsightsString = $ENV:APPLICATIONINSIGHTS_CONNECTION_STRING
    $splitApplicationInsightsString = $applicationInsightsString -split ";"

    $applicationInsightsConfig = New-Object PSObject
    foreach ($item in $splitApplicationInsightsString) {
        $keyValue = $item -split "="
        $applicationInsightsConfig | Add-Member -NotePropertyName $keyValue[0] -NotePropertyValue $keyValue[1]
    }
    
    $applicationInsightsClient = New-Object -TypeName Microsoft.ApplicationInsights.TelemetryClient
    $applicationInsightsClient.InstrumentationKey = $applicationInsightsConfig.InstrumentationKey

    return $applicationInsightsClient
}