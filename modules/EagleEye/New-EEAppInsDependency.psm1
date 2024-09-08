<#
.SYNOPSIS
This function sends a dependency log to Application Insights.

.DESCRIPTION
The New-EEAppInsDependency function is used to send a dependency log to Application Insights. It takes in parameters for the AppInsRequestActivity and AppInsParentRequestActivity. It creates a new dependency telemetry object and sends it to Application Insights.

.PARAMETER AppInsRequestActivity
This parameter specifies the Application Insights Request Activity.

.PARAMETER AppInsParentRequestActivity
This parameter specifies the parent Application Insights Request Activity.

.EXAMPLE
New-EEAppInsDependency -AppInsRequestActivity $AppInsRequestActivity -AppInsParentRequestActivity $AppInsParentRequestActivity

This example shows how to use the function to send a dependency log to Application Insights.

.NOTES
Author: Michael Montana
GitHub: https://github.com/michael-montana
#>
function New-EEAppInsDependency(){
    param(
        [object]$AppInsParentActivity,
        [string]$CloudRoleName,
        [string]$CloudRoleInstance
    )

    #Check if the AppInsParentActivity or CloudRoleName is not null, if it is then return null otheriwse continue
    if([String]::IsNullOrEmpty($AppInsParentActivity) -or [String]::IsNullOrEmpty($CloudRoleName)){
        return $null
    }

    $isAppInsDependencyCallSuccessfull = $true

    #New AppInsDependencyActivity
    $AppInsDependencyActivity = New-EEAppInsActivity -CloudRoleName $CloudRoleName -AppInsParentActivity $AppInsParentActivity -CloudRoleInstance $AppInsParentActivity.CloudRoleInstance

    #Stopwatch for Duration
    $StopWatch = $AppInsParentActivity.Stopwatch.PSObject.Copy()
    $StopWatch.Stop() | Out-Null
    $lapTime = $StopWatch.Elapsed
    $DurationInMilliseconds = $lapTime.TotalMilliseconds

    Send-EEAppInsDependencyLog -DurationInMilliseconds $DurationInMilliseconds -CallerFunctionName $AppInsParentActivity.CloudRoleName -AppInsDependencyActivity $AppInsDependencyActivity -Success $isAppInsDependencyCallSuccessfull

    #New AppInsRequestActivity
    $AppInsRequestActivity = New-EEAppInsActivity -CloudRoleName $CloudRoleName -AppInsParentActivity $AppInsDependencyActivity -CloudRoleInstance $(if ($CloudRoleInstance) { $CloudRoleInstance } else { $AppInsParentActivity.CloudRoleInstance })   
     
    return $AppInsRequestActivity
}