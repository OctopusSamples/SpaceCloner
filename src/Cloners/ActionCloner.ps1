function Copy-OctopusProcessStepAction
{
    param(
        $sourceAction,
        $sourceChannelList,
        $destinationChannelList,
        $sourceData,
        $destinationData
    )
        
    if ((Get-OctopusDestinationSupportsActionType -action $sourceAction -destinationData $destinationData) -eq $false)
    {
        return $null
    }

    $action = Copy-OctopusObject -ItemToCopy $sourceAction -ClearIdValue $true -SpaceId $null   

    $action.Environments = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $action.Environments
    $action.ExcludedEnvironments = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $action.ExcludedEnvironments
    $action.Channels = Convert-SourceIdListToDestinationIdList -SourceList $SourceChannelList -DestinationList $destinationChannelList -IdList $action.Channels
    
    Convert-OctopusProcessActionWorkerPoolId -action $action -sourceData $sourceData -destinationData $destinationData                
    Convert-OctopusProcessActionStepTemplate -action $action -sourceData $sourceData -destinationData $destinationData
    Convert-OctopusProcessActionManualIntervention -action $action -sourceData $sourceData -destinationData $destinationData
    Convert-OctopusProcessActionFeedId -action $action -sourceData $sourceData -destinationData $destinationData    
    Convert-OctopusProcessActionPackageList -action $action
        
    return $action    
}

function Get-OctopusDestinationSupportsActionType
{
    param(
        $action,
        $destinationData
    )

    if ($action.ActionType -eq "Octopus.AwsRunScript" -and $destinationData.HasAWSSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.AwsRunCloudFormation" -and $destinationData.HasAWSSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.AwsDeleteCloudFormation" -and $destinationData.HasAWSSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.AwsUploadS3" -and $destinationData.HasAWSSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.AwsApplyCloudFormationChangeSet" -and $destinationData.HasAWSSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.KubernetesDeployContainers" -and $destinationData.HasK8sSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.KubernetesDeployService" -and $destinationData.HasK8sSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.KubernetesDeployIngress" -and $destinationData.HasK8sSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.KubernetesDeployConfigMap" -and $destinationData.HasK8sSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.KubernetesDeploySecret" -and $destinationData.HasK8sSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.HelmChartUpgrade" -and $destinationData.HasK8sSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.TerraformApply" -and $destinationData.HasTerraformSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.TerraformDestroy" -and $destinationData.HasTerraformSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.TerraformPlan" -and $destinationData.HasTerraformSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($action.ActionType -eq "Octopus.TerraformPlanDestroy" -and $destinationData.HasTerraformSupport -eq $false)
    {
        Write-YellowOutput -Message "The action $($action.Name) is an $($action.ActionType), which isn't supported by the destination, skipping"
        return $false
    }
    
    return $true
}

function Convert-OctopusProcessActionWorkerPoolId
{
    param (
        $action,
        $sourceData,
        $destinationData
    )

    if ($sourceData.HasWorkers -and $destinationData.HasWorkers -and (Test-OctopusObjectHasProperty -objectToTest $action -propertyName "WorkerPoolId"))
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
        Write-CleanUpOutput "$($action.Name) is a manual intervention, converting responsible team to built in team 'team-managers'"                                        
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
        Write-CleanUpOutput "Removed package references from $($action.Name)"
        $action.Packages = @()
    }
}