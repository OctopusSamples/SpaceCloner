function Copy-OctopusProcessStepAction
{
    param(
        $sourceAction,
        $sourceChannelList,
        $destinationChannelList,
        $sourceData,
        $destinationData
    )            

    $action = Copy-OctopusObject -ItemToCopy $sourceAction -ClearIdValue $true -SpaceId $null   

    $action.Environments = @(Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $action.Environments)
    $action.ExcludedEnvironments = @(Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $action.ExcludedEnvironments)
    $action.Channels = @(Convert-SourceIdListToDestinationIdList -SourceList $SourceChannelList -DestinationList $destinationChannelList -IdList $action.Channels)
    
    Convert-OctopusProcessActionWorkerPoolId -action $action -sourceData $sourceData -destinationData $destinationData                
    Convert-OctopusProcessActionStepTemplate -action $action -sourceData $sourceData -destinationData $destinationData
    Convert-OctopusProcessActionManualIntervention -action $action -sourceData $sourceData -destinationData $destinationData
    Convert-OctopusProcessActionFeedId -action $action -sourceData $sourceData -destinationData $destinationData    
    Convert-OctopusProcessActionPackageList -action $action
        
    return $action    
}

function Convert-OctopusProcessActionWorkerPoolId
{
    param (
        $action,
        $sourceData,
        $destinationData
    )

    if ((Test-OctopusObjectHasProperty -objectToTest $action -propertyName "WorkerPoolId"))
    {
        if ($null -ne $action.WorkerPoolId)
        {
            $action.WorkerPoolId = Convert-SourceIdToDestinationId -SourceList $SourceData.WorkerPoolList -DestinationList $DestinationData.WorkerPoolList -IdValue $action.WorkerPoolId                             
        }
    }
}

function Convert-OctopusProcessActionStepTemplate
{
    param (
        $action,
        $sourceData,
        $destinationData
    )

    if (Test-OctopusObjectHasProperty -objectToTest $action.Properties -propertyName "Octopus.Action.Template.Id")
    {                                        
        $action.Properties.'Octopus.Action.Template.Id' = Convert-SourceIdToDestinationId -SourceList $sourceData.StepTemplates -DestinationList $destinationData.StepTemplates -IdValue $action.Properties.'Octopus.Action.Template.Id' 
        $stepTemplate = Get-OctopusItemById -ItemList $destinationData.StepTemplates -ItemId $action.Properties.'Octopus.Action.Template.Id'
        $action.Properties.'Octopus.Action.Template.Version' = $stepTemplate.Version

        foreach ($parameter in $stepTemplate.Parameters)
        {                                
            if ((Test-OctopusObjectHasProperty -objectToTest $action.Properties -propertyName $parameter.Name))
            {
                $controlType = $parameter.DisplaySettings.'Octopus.ControlType'
                Write-OctopusVerbose "$($parameter.Name) is control type is $controlType"
                
                if ($controlType -eq "Package")
                {
                    $action.Properties.$($parameter.Name) = ""
                }    
                elseif ($controlType -eq "Sensitive")            
                {
                    Write-OctopusPostCloneCleanUp "Set $($parameter.Name) in $($action.Name) to Dummy Value"
                    $action.Properties.$($parameter.Name) = "DUMMY VALUE"
                }
            }            
        }
    }
}

function Convert-OctopusProcessActionManualIntervention
{
    param (
        $action,
        $sourceData,
        $destinationData
    )

    if (Test-OctopusObjectHasProperty -objectToTest $action.Properties -propertyName "Octopus.Action.Manual.ResponsibleTeamIds")
    {
        Write-OctopusPostCloneCleanUp "$($action.Name) is a manual intervention, converting responsible team to built in team 'team-managers'"                                        
        $action.Properties.'Octopus.Action.Manual.ResponsibleTeamIds' = "team-managers"
    }
}

function Convert-OctopusProcessActionFeedId
{
    param (
        $action,
        $sourceData,
        $destinationData
    )

    if (Test-OctopusObjectHasProperty -objectToTest $action.Properties -propertyName "Octopus.Action.Package.FeedId")
    {
        $action.Properties.'Octopus.Action.Package.FeedId' = Convert-SourceIdToDestinationId -SourceList $sourceData.FeedList -DestinationList $destinationData.FeedList -IdValue $action.Properties.'Octopus.Action.Package.FeedId'
    }
}

function Convert-OctopusProcessActionPackageList
{
    param ($action)

    if ($action.Packages.Length -gt 0)
    {        
        Write-OctopusPostCloneCleanUp "Removed package references from $($action.Name)"
        $action.Packages = @()
    }
}