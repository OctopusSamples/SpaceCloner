. ($PSScriptRoot + ".\..\Core\Logging.ps1")
. ($PSScriptRoot + ".\..\Core\Util.ps1")

. ($PSScriptRoot + ".\..\DataAccess\OctopusDataAdapter.ps1")
. ($PSScriptRoot + ".\..\DataAccess\OctopusDataFactory.ps1")

function Copy-ProcessStepAction
{
    param(
        $sourceAction,
        $sourceChannelList,
        $destinationChannelList,
        $sourceData,
        $destinationData
    )
        
    $action = Copy-OctopusObject -ItemToCopy $sourceAction -ClearIdValue $true -SpaceId $null

    if ($action.ActionType -eq "Octopus.AwsRunScript" -and $destinationData.HasAWSSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an AWS Script, which isn't supported by the destination, skipping"
        return $null
    }
    
    if ($sourceData.HasWorkers -and $destinationData.HasWorkers -and (Test-OctopusObjectHasProperty -objectToTest $action -propertyName "WorkerPoolId"))
    {
        if ($null -ne $action.WorkerPoolId)
        {
            $action.WorkerPoolId = Convert-SourceIdToDestinationId -SourceList $SourceData.WorkerPoolList -DestinationList $DestinationData.WorkerPoolList -IdValue $action.WorkerPoolId                             
        }
    }
    
    $NewEnvironmentIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $action.Environments            
    $action.Environments = @($NewEnvironmentIds)

    $NewEnvironmentIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $action.ExcludedEnvironments            
    $action.ExcludedEnvironments = @($NewEnvironmentIds)

    $NewChannelIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceChannelList -DestinationList $destinationChannelList -IdList $action.Channels
    $action.Channels = @($NewChannelIds)

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
                Write-VerboseOutput "$($parameter.Name) is control type is $controlType"
                
                if ($controlType -eq "Package")
                {
                    $action.Properties.$($parameter.Name) = ""
                }    
                elseif ($controlType -eq "Sensitive")            
                {
                    Write-CleanUpOutput "Set $($parameter.Name) in $($action.Name) to Dummy Value"
                    $action.Properties.$($parameter.Name) = "DUMMY VALUE"
                }
            }            
        }
    }

    if (Test-OctopusObjectHasProperty -objectToTest $action.Properties -propertyName "Octopus.Action.Manual.ResponsibleTeamIds")
    {                                        
        $action.Properties.'Octopus.Action.Manual.ResponsibleTeamIds' = "team-managers"
    }

    if (Test-OctopusObjectHasProperty -objectToTest $action.Properties -propertyName "Octopus.Action.Package.FeedId")
    {
        $action.Properties.'Octopus.Action.Package.FeedId' = Convert-SourceIdToDestinationId -SourceList $sourceData.FeedList -DestinationList $destinationData.FeedList -IdValue $action.Properties.'Octopus.Action.Package.FeedId'
    }

    if ($action.Packages.Length -gt 0)
    {        
        Write-CleanUpOutput "Removed package references from $($action.Name)"
        $action.Packages = @()
    }
    
    return $action    
}

function Copy-OctopusDeploymentProcess
{
    param(
        $sourceChannelList,
        $destinationChannelList,
        $sourceData,
        $destinationData,
        $sourceDeploymentProcessSteps,
        $destinationDeploymentProcessSteps
    )

    Write-VerboseOutput "Looping through the source steps to get them added"
    $newDeploymentProcessSteps = @()
    foreach($step in $sourceDeploymentProcessSteps)
    {
        $matchingStep = Get-OctopusItemByName -ItemList $destinationDeploymentProcessSteps -ItemName $step.Name
        
        $newStep = $false
        if ($null -eq $matchingStep)
        {
            Write-VerboseOutput "The step $($step.Name) was not found, cloning from source and removing id"            
            $stepToAdd = Copy-OctopusObject -ItemToCopy $step -ClearIdValue $true -SpaceId $null            
            $newStep = $true
        }
        else
        {
            Write-VerboseOutput "Matching step $($step.Name) found, using that existing step"
            $stepToAdd = Copy-OctopusObject -ItemToCopy $matchingStep -ClearIdValue $false -SpaceId $null
        }

        Write-VerboseOutput "Looping through the source actions to add them to the step"
        $newStepActions = @()
        foreach ($action in $step.Actions)
        {
            $matchingAction = Get-OctopusItemByName -ItemList $stepToAdd.Actions -ItemName $action.Name

            if ($null -eq $matchingAction -or $newStep -eq $true)
            {
                Write-VerboseOutput "The action $($action.Name) doesn't exist for the step, adding that to the list"
                $clonedStep = Copy-ProcessStepAction -sourceAction $action -sourceChannelList $sourceChannelList -destinationChannelList $destinationChannelList -sourceData $sourceData -destinationData $destinationData         

                if ($null -ne $clonedStep)
                {
                    $newStepActions += $clonedStep
                }
            }            
            else
            {
                Write-VerboseOutput "The action $($action.Name) already exists for the step, adding existing item to list"
                $newStepActions += Copy-OctopusObject -ItemToCopy $matchingAction -ClearIdValue $false -SpaceId $null
            }
        }

        Write-VerboseOutput "Looping through the destination step to make sure we didn't miss any actions"
        foreach ($action in $stepToAdd.Actions)
        {
            $matchingAction = Get-OctopusItemByName -ItemList $step.Actions -ItemName $action.Name

            if ($null -eq $matchingAction)
            {
                Write-VerboseOutput "The action $($action.Name) didn't exist at the source, adding that back to the destination list"
                $newStepActions += Copy-OctopusObject -ItemToCopy $action -ClearIdValue $false -SpaceId $null
            }
        }
        
        $stepToAdd.Actions = @($newStepActions)

        if ($stepToAdd.Actions.Length -gt 0)
        {
            $newDeploymentProcessSteps += $stepToAdd
        }
    }

    Write-VerboseOutput "Looping through the destination deployment process steps to make sure we didn't miss anything"
    foreach ($step in $destinationDeploymentProcessSteps)
    {
        $matchingStep = Get-OctopusItemByName -ItemList $sourceDeploymentProcessSteps -ItemName $step.Name

        if ($null -eq $matchingStep)
        {
            Write-VerboseOutput "The step $($step.Name) didn't exist in the source, adding that back to the destiantion list"
            $newDeploymentProcessSteps += Copy-OctopusObject -ItemToCopy $step -ClearIdValue $false -SpaceId $null
        }
    }

    return @($newDeploymentProcessSteps)
}