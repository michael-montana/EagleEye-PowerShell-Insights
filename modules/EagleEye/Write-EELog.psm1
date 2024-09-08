<#
.SYNOPSIS
This function writes logs with different formats based on the size parameter.

.DESCRIPTION
The Write-EELog function is used to write logs. It takes in parameters for the Message, AppInsRequestActivity, and delimiterSize. It checks if the script is running in Azure Function or in Console and writes logs accordingly. It also logs to Application Insights.

.PARAMETER Message
This parameter specifies the message to be logged.

.PARAMETER AppInsRequestActivity
This parameter specifies the Application Insights Request Activity.

.PARAMETER delimiterSize
This parameter specifies the size of the delimiter. It can be "large", "small", or "exception".

.EXAMPLE
Write-EELog -Message "This is a test message" -AppInsRequestActivity $AppInsRequestActivity -delimiterSize "large"

This example shows how to use the function to write a large log.

.NOTES
Author: Michael Montana
Email: michael_montana@outlook.com
#>
function Write-EELog(){
    param(
        # Set the parameter message to pipeline input
        [Parameter(ValueFromPipeline = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [object]$AppInsRequestActivity,
        [Parameter(Mandatory = $false)]
        [string]$delimiterSize
    )

    # Check if running in Azure Function or in Console
    if ($null -ne $env:WEBSITE_INSTANCE_ID) {
        $scriptIsRunningInAzureFunction = $true
    } else {
        $scriptIsRunningInAzureFunction = $false
    }

    # fixAzureLogStreamOrderBySlowingDownScript 
    # if($env:fixAzureLogStreamOrderBySlowingDownScript -ne $null){
    #     $slowDown = $true
    # } else {
    #     $slowDown = $false
    # }
    $slowDown = $true

    # Determine if AppInsRequestActivity is provided and set prefix
    $prefix = if ($AppInsRequestActivity) { "$($AppInsRequestActivity.telemetryClient.Context.Cloud.RoleInstance): " } else { "" }


    $scriptBlock = {
        param($size, $slowDown, $prefix)
        if($size -eq "large"){
            $slowDown ? (Start-Sleep -Seconds 0.1):$null
            Write-Host "$prefix|"
            $slowDown ? (Start-Sleep -Seconds 0.1):$null
            Write-Host "$prefix#####################################"
            $slowDown ? (start-sleep -Seconds 0.1):$null
            Write-Host "$prefix## ▒▒███████▒▒"
            $slowDown ? (start-sleep -Seconds 0.1):$null
            Write-Host "$prefix## ▒█████████▒"
            $slowDown ? (start-sleep -Seconds 0.1):$null
            Write-Host "$prefix## █ Section █ $Message"
            $slowDown ? (start-sleep -Seconds 0.1):$null
            Write-Host "$prefix## ▒█████████▒"
            $slowDown ? (start-sleep -Seconds 0.1):$null
            Write-Host "$prefix## ▒▒███████▒▒"
            $slowDown ? (start-sleep -Seconds 0.1):$null
            Write-Host "$prefix#####################################"
            $slowDown ? (start-sleep -Seconds 0.1):$null
        } elseif ($size -eq "small"){
            $slowDown ? (Start-Sleep -Seconds 0.1):$null
            Write-Host "$prefix|"
            $slowDown ? (Start-Sleep -Seconds 0.1):$null
            Write-Host "$prefix## ▒▒██▒▒ $Message"
            $slowDown ? (Start-Sleep -Seconds 0.1):$null
            Write-Host "$prefix## ▒▒██▒▒"
            $slowDown ? (Start-Sleep -Seconds 0.1):$null
        } elseif ($size -eq "exception"){
            Start-Sleep -Seconds 0.1
            Write-Host -ForegroundColor Red "$prefix#####################################"
            Start-Sleep -Seconds 0.1
            Write-Host -ForegroundColor Red "$prefix  █████████  "
            Start-Sleep -Seconds 0.1
            Write-Host -ForegroundColor Red "$prefix █████!█████ Exception"
            Start-Sleep -Seconds 0.1
            Write-Host -ForegroundColor Red "$prefix  █████████  "
            Start-Sleep -Seconds 0.1
            Write-host "$prefix $Message"
            Start-Sleep -Seconds 0.1
            Write-Host -ForegroundColor Red "$prefix#####################################"

        } else {
            $totalMessage = $prefix
            $totalMessage += $Message
            Write-Host $totalMessage
        }
    }
    
    if ($scriptIsRunningInAzureFunction) {
        #$scriptBlockString = $scriptBlock.ToString().Replace('Write-Host', 'Write-Output') -replace ' -ForegroundColor \w+', ''
        $scriptBlockString = $scriptBlock.ToString() -replace ' -ForegroundColor \w+', '' #No ".Replace('Write-Host', 'Write-Output')" otherwise all the Write-Output will be included in a return value of a function for what ever reason, even if you specify the return value to be something else
        $scriptBlock = [scriptblock]::Create($scriptBlockString)
    }
    
    #Execute the Message
    & $scriptBlock $delimiterSize $slowDown $prefix

    if(-not [String]::IsNullOrEmpty($AppInsRequestActivity)) {
        # Log to Application Insights
    
        #Applicaiton Insights Client
        $applicationInsightsClient = $AppInsRequestActivity.TelemetryClient
    
        #Set the RoleName
        $applicationInsightsClient.Context.Cloud.RoleName = $AppInsRequestActivity.CloudRoleName
        $applicationInsightsClient.Context.Cloud.RoleInstance = $AppInsRequestActivity.CloudRoleInstance
    
        # Create a new trace telemetry object
        $telemetry = New-Object -TypeName Microsoft.ApplicationInsights.DataContracts.TraceTelemetry
        $telemetry.Message = "$prefix$Message"
        $telemetry.Context.Operation.Id = $AppInsRequestActivity.OperationId
        $telemetry.Context.Operation.ParentId = $AppInsRequestActivity.Id
        $applicationInsightsClient.TrackTrace($telemetry)
        $applicationInsightsClient.Flush()
    }

}