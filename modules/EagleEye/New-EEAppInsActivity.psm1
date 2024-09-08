<#
.SYNOPSIS
This function creates a new Application Insights activity.

.DESCRIPTION
The New-EEAppInsActivity function is used to create a new Application Insights activity. It takes in parameters for the CloudRoleName, CloudRoleInstance, and AppInsParentActivity. It creates a new activity and sets the properties accordingly.

.PARAMETER CloudRoleName
This parameter specifies the name of the cloud role.

.PARAMETER CloudRoleInstance
This parameter specifies the instance of the cloud role.

.PARAMETER AppInsParentActivity
This parameter specifies the parent Application Insights activity.

.EXAMPLE
New-EEAppInsActivity -CloudRoleName "RoleName" -CloudRoleInstance "RoleInstance" -AppInsParentActivity $AppInsParentActivity

This example shows how to use the function to create a new Application Insights activity.

.NOTES
Author: Michael Montana
GitHub: https://github.com/michael-montana
#>
function New-EEAppInsActivity (){
    param(    
        [Parameter(Mandatory=$false)]
        [string]$CloudRoleName,
        [Parameter(Mandatory=$false)]
        [string]$CloudRoleInstance,
        [Parameter(Mandatory=$false)]
        [object]$AppInsParentActivity
    )

    # Check if all three parameters are empty or null, if yes, then return null
    if([String]::IsNullOrEmpty($CloudRoleName) -and [String]::IsNullOrEmpty($CloudRoleInstance) -and [String]::IsNullOrEmpty($AppInsParentActivity)){
        return $null
    }

    if($PSScriptRoot -notlike "*C:\home\site\wwwroot\*"){
        #running in Console and not in Azure Function Environment
        $currentAzureFunctionName = $currentFunctionName
    }else{
        #running in Azure Function Environment
        $currentAzureFunctionName = ([string]$PSScriptRoot).replace("C:\home\site\wwwroot\", "")
    }

    #new System.Diagnostics.Activity("RequestActivity")
    $activity = New-Object System.Diagnostics.Activity("RequestActivity")
    $activity.Start() | Out-Null

    #new PS Custom object
    $appInsActivity = New-Object PSObject

    #Context.Cloud.RoleName
    $appInsActivity | Add-Member -MemberType NoteProperty -Name CloudRoleName -Value "$CloudRoleName"

    #Context.Cloud.RoleName
    $appInsActivity | Add-Member -MemberType NoteProperty -Name CloudRoleInstance -Value "$CloudRoleInstance"

    #Context.Operation.Id
    $appInsActivity | Add-Member -MemberType NoteProperty -Name Id -Value $activity.spanId

    #Stopwatch for Duration
    $stopWatch = New-Object System.Diagnostics.Stopwatch
    $stopWatch.Start() | Out-Null
    $appInsActivity | Add-Member -MemberType NoteProperty -Name Stopwatch -Value $stopWatch

    $appInsActivity | Add-Member -MemberType NoteProperty -Name TelemetryClient -Value (New-EEAppInsTelemetryClient)

    #OperationProperties
    if([String]::IsNullOrEmpty($AppInsParentActivity)){
        $appInsActivity | Add-Member -MemberType NoteProperty -Name OperationParentId -Value $activity.RootId
        $appInsActivity | Add-Member -MemberType NoteProperty -Name OperationId -Value $activity.RootId
    }else{
        if($currentAzureFunctionName -eq $AppInsParentActivity.CloudRoleName){
            $appInsActivity | Add-Member -MemberType NoteProperty -Name OperationParentId -Value $AppInsParentActivity.OperationId
        }else{
            $appInsActivity | Add-Member -MemberType NoteProperty -Name OperationParentId -Value $AppInsParentActivity.Id
        }
        $appInsActivity | Add-Member -MemberType NoteProperty -Name OperationId -Value $AppInsParentActivity.OperationId
    }

    return $appInsActivity

}