function Copy-OctopusProjects
{
    param(
        $SourceData,
        $DestinationData,
        $CloneScriptOptions
    )  
    
    if ([string]::IsNullOrWhiteSpace($CloneScriptOptions.ChildProjectsToSync) -eq $false)
    {
        Write-YellowOutput "You have elected to sync child projects with a master template, skipping the normal project cloner"
        return
    }

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.ProjectList -itemType "Projects" -filters $cloneScriptOptions.ProjectsToClone

    foreach($project in $filteredList)
    {
        $createdNewProject = Copy-OctopusProjectSettings -sourceData $SourceData -destinationData $DestinationData -sourceProject $project               
        
        Write-GreenOutput "Reloading destination projects"        
        
        $destinationData.ProjectList = Get-OctopusProjectList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId       

        $destinationProject = Get-OctopusItemByName -ItemList $DestinationData.ProjectList -ItemName $project.Name

        $sourceChannels = Get-OctopusApiItemList -EndPoint "projects/$($project.Id)/channels" -ApiKey $SourceData.OctopusApiKey -OctopusUrl $SourceData.OctopusUrl -SpaceId $SourceData.SpaceId
        $destinationChannels = Get-OctopusApiItemList -EndPoint "projects/$($destinationProject.Id)/channels" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId

        Copy-OctopusProjectChannels -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -destinationProject $destinationProject -sourceData $SourceData -destinationData $DestinationData
        Copy-OctopusProjectDeploymentProcess -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -sourceProject $project -destinationProject $destinationProject -sourceData $SourceData -destinationData $DestinationData 

        if ($CloneScriptOptions.CloneProjectRunbooks -eq $true)
        {
            Copy-OctopusProjectRunbooks -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -destinationProject $destinationProject -sourceProject $project -destinationData $DestinationData -sourceData $SourceData            
        }

        Copy-OctopusProjectVariables -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -destinationProject $destinationProject -sourceProject $project -destinationData $DestinationData -sourceData $SourceData -cloneScriptOptions $CloneScriptOptions -createdNewProject $createdNewProject        
    }
}

function Copy-OctopusProjectSettings
{
    param(
        $sourceData,
        $destinationData,
        $sourceProject
    )

    $matchingProject = Get-OctopusItemByName -ItemList $DestinationData.ProjectList -ItemName $sourceProject.Name               

    if ($null -eq $matchingProject)
    {            
        $copyOfProject = Copy-OctopusObject -ItemToCopy $sourceProject -ClearIdValue $true -SpaceId $destinationData.SpaceId
        
        $copyOfProject.DeploymentProcessId = $null
        $copyOfProject.VariableSetId = $null
        $copyOfProject.ClonedFromProjectId = $null        

        $VariableSetIds = @(Convert-SourceIdListToDestinationIdList -SourceList $SourceData.VariableSetList -DestinationList $DestinationData.VariableSetList -IdList $copyOfProject.IncludedLibraryVariableSetIds)
        $copyOfProject.IncludedLibraryVariableSetIds = @($VariableSetIds)
        $copyOfProject.ProjectGroupId = Convert-SourceIdToDestinationId -SourceList $SourceData.ProjectGroupList -DestinationList $DestinationData.ProjectGroupList -IdValue $copyOfProject.ProjectGroupId
        $copyOfProject.LifeCycleId = Convert-SourceIdToDestinationId -SourceList $SourceData.LifeCycleList -DestinationList $DestinationData.LifeCycleList -IdValue $copyOfProject.LifeCycleId        

        Write-CleanUpOutput "Cloned from project $($sourceProject.Name), resetting the versioning template to the default, removing the automatic release creation"
        $copyOfProject.VersioningStrategy.Template = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
        $copyOfProject.VersioningStrategy.DonorPackage = $null
        $copyOfProject.VersioningStrategy.DonorPackageStepId = $null
        $copyOfProject.ReleaseCreationStrategy.ChannelId = $null
        $copyOfProject.ReleaseCreationStrategy.ReleaseCreationPackage = $null
        $copyOfProject.ReleaseCreationStrategy.ReleaseCreationPackageStepId = $null
        
        Save-OctopusApiItem -Item $copyOfProject -Endpoint "projects" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId                 

        return $true
    }
    else
    {            
        $matchingProject.Description = $sourceProject.Description                   

        Save-OctopusApiItem -Item $matchingProject -Endpoint "projects" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId

        return $false
    }    
}

