. ($PSScriptRoot + ".\..\Core\Logging.ps1")
. ($PSScriptRoot + ".\..\Core\Util.ps1")

. ($PSScriptRoot + ".\..\DataAccess\OctopusDataAdapter.ps1")
. ($PSScriptRoot + ".\..\DataAccess\OctopusDataFactory.ps1")

function Copy-OctopusProjectChannels
{
    param(
        $sourceChannelList,
        $destinationChannelList,
        $destinationProject,
        $sourceData,
        $destinationData
    )

    foreach($channel in $sourceChannelList)
    {
        $matchingChannel = Get-OctopusItemByName -ItemList $destinationChannelList -ItemName $channel.Name

        if ($null -eq $matchingChannel)
        {
            $cloneChannel = Copy-OctopusObject -ItemToCopy $channel -ClearIdValue $false -SpaceId $destinationData.SpaceId
            $cloneChannel.Id = $null
            $cloneChannel.ProjectId = $destinationProject.Id
            if ($null -ne $cloneChannel.LifeCycleId)
            {
                $cloneChannel.LifeCycleId = Convert-SourceIdToDestinationId -SourceList $SourceData.LifeCycleList -DestinationList $DestinationData.LifeCycleList -IdValue $cloneChannel.LifeCycleId
            }

            $cloneChannel.Rules = @()

            Write-GreenOutput "The channel $($channel.Name) does not exist for the project $($destinationProject.Name), creating one now.  Please note, I cannot create version rules, so those will be emptied out"
            Save-OctopusApiItem -Item $cloneChannel -Endpoint "channels" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId
        }        
        else
        {
            Write-GreenOutput "The channel $($channel.Name) already exists for project $($destinationProject.Name).  Skipping it."
        }
    }
}

function Copy-OctopusProjectDeploymentProcess
{
    param(
        $sourceChannelList,
        $destinationChannelList,
        $destinationProject,        
        $sourceData,
        $destinationData
    )

    Write-GreenOutput "Syncing deployment process for $($destinationProject.Name)"
    $sourceDeploymentProcess = Get-OctopusApi -EndPoint $project.Links.DeploymentProcess -ApiKey $SourceData.OctopusApiKey -OctopusUrl $sourceData.OctopusUrl -SpaceId $null
    $destinationDeploymentProcess = Get-OctopusApi -EndPoint $destinationProject.Links.DeploymentProcess -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $null
    
    $destinationDeploymentProcess.Steps = @(Copy-OctopusDeploymentProcess -sourceChannelList $sourceChannelList -destinationChannelList $destinationChannelList -sourceData $sourceData -destinationData $destinationData -sourceDeploymentProcessSteps $sourceDeploymentProcess.Steps -destinationDeploymentProcessSteps $destinationDeploymentProcess.Steps)

    Save-OctopusApiItem -Item $destinationDeploymentProcess -Endpoint "deploymentprocesses" -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId
}

function Copy-OctopusProject
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

        $VariableSetIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.VariableSetList -DestinationList $DestinationData.VariableSetList -IdList $copyOfProject.IncludedLibraryVariableSetIds            
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
        $matchingProject.TenantedDeploymentMode = $sourceProject.TenantedDeploymentMode
        $matchingProject.DefaultGuidedFailureMode = $sourceProject.DefaultGuidedFailureMode
        $matchingProject.ReleaseNotesTemplate = $sourceProject.ReleaseNotesTemplate 
        $matchingProject.DeploymentChangesTemplate = $sourceProject.DeploymentChangesTemplate
        $matchingProject.Description = $sourceProject.Description                   

        Save-OctopusApiItem -Item $matchingProject -Endpoint "projects" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId

        return $false
    }    
}

function Copy-OctopusProjectRunbooks
{
    param(
        $sourceChannelList,
        $destinationChannelList,
        $destinationProject,        
        $sourceProject,
        $sourceData,
        $destinationData
    )

    if ($sourceData.HasRunbooks -eq $false -or $destinationData.HasRunbooks -eq $false)
    {
        Write-YellowOutput "The source or destination do not have runbooks, skipping the runbook clone process"
        return
    }

    $sourceRunbooks = Get-OctopusApiItemList -EndPoint "projects/$($sourceProject.Id)/runbooks" -ApiKey $sourcedata.OctopusApiKey -OctopusUrl $sourceData.OctopusUrl -SpaceId $sourceData.SpaceId
    $destinationRunbooks = Get-OctopusApiItemList -EndPoint "projects/$($destinationProject.Id)/runbooks" -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId

    foreach ($runbook in $sourceRunbooks)
    {
        $destinationRunbook = Get-OctopusItemByName -ItemList $destinationRunbooks -ItemName $runbook.Name

        $canProceed = $false
        if ($null -eq $destinationRunbook)
        {
            $runbookToClone = Copy-OctopusObject -ItemToCopy $runbook -SpaceId $destinationData.SpaceId -ClearIdValue $true
            
            $runbookToClone.ProjectId = $destinationProject.Id
            $runbookToClone.PublishedRunbookSnapshotId = $null
            $runbookToClone.RunbookProcessId = $null            

            Write-GreenOutput "The runbook $($runbook.Name) for $($destinationProject.Name) doesn't exist, creating it now"
            $destinationRunbook = Save-OctopusApiItem -Item $runbookToClone -Endpoint "runbooks" -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId
            $canProceed = $true
        }
        
        $sourceRunbookProcess = Get-OctopusApi -EndPoint $runbook.Links.RunbookProcesses -ApiKey $sourcedata.OctopusApiKey -OctopusUrl $sourceData.OctopusUrl -SpaceId $null
        $destinationRunbookProcess = Get-OctopusApi -EndPoint $destinationRunbook.Links.RunbookProcesses -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $null

        Write-CleanUpOutput "Syncing deployment process for $($runbook.Name)"        
        $destinationRunbookProcess.Steps = @(Copy-OctopusDeploymentProcess -sourceChannelList $sourceChannelList -destinationChannelList $destinationChannelList -sourceData $sourceData -destinationData $destinationData -sourceDeploymentProcessSteps $sourceRunbookProcess.Steps -destinationDeploymentProcessSteps $destinationRunbookProcess.Steps)
            
        Save-OctopusApiItem -Item $destinationRunbookProcess -Endpoint "runbookProcesses" -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId
    }
}

function Copy-OctopusProjectVariables
{
    param(
        $sourceChannelList,
        $destinationChannelList,
        $destinationProject,        
        $sourceProject,
        $sourceData,
        $destinationData,
        $cloneScriptOptions,
        $createdNewProject
    )    

    if ($createdNewProject -eq $true -or $cloneScriptOptions.OverwriteExistingVariables -eq $true)
    {
        $sourceVariableSetVariables = Get-OctopusApi -EndPoint $sourceProject.Links.Variables -ApiKey $sourceData.OctopusApiKey -OctopusUrl $sourceData.OctopusUrl -SpaceId $null
        $destinationVariableSetVariables = Get-OctopusApi -EndPoint $destinationProject.Links.Variables -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $null

        $SourceProjectData = @{
            ChannelList = $sourceChannelList;
            RunbookList = @()
            Project = $sourceProject    
        }

        if ($sourceData.HasRunBooks -eq $true)
        {
            $SourceProjectData.RunbookList = Get-OctopusApiItemList -EndPoint "projects/$($sourceProject.Id)/runbooks" -ApiKey $sourcedata.OctopusApiKey -OctopusUrl $sourceData.OctopusUrl -SpaceId $sourceData.SpaceId;
        }

        $DestinationProjectData = @{
            ChannelList = $destinationChannelList;
            RunbookList = @();
            Project = $destinationProject
        }

        if ($destinationData.HasRunBooks -eq $true)
        {
            $DestinationProjectData.RunbookList = Get-OctopusApiItemList -EndPoint "projects/$($destinationProject.Id)/runbooks" -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId;
        }

        Write-CleanUpOutput "Cloning variables for project $($destinationProject.Name)"

        Copy-OctopusVariableSetValues -SourceVariableSetVariables $sourceVariableSetVariables -DestinationVariableSetVariables $destinationVariableSetVariables -SourceData $SourceData -DestinationData $DestinationData -SourceProjectData $SourceProjectData -DestinationProjectData $DestinationProjectData -CloneScriptOptions $cloneScriptOptions
    }
}

function Copy-OctopusProjects
{
    param(
        $SourceData,
        $DestinationData,
        $CloneScriptOptions
    )    

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.ProjectList -itemType "Projects" -filters $cloneScriptOptions.ProjectsToClone

    foreach($project in $filteredList)
    {
        $createdNewProject = Copy-OctopusProject -sourceData $SourceData -destinationData $DestinationData -sourceProject $project               
        
        Write-GreenOutput "Reloading destination projects"        
        
        $destinationData.ProjectList = Get-OctopusProjectList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId       

        $destinationProject = Get-OctopusItemByName -ItemList $DestinationData.ProjectList -ItemName $project.Name

        $sourceChannels = Get-OctopusApiItemList -EndPoint "projects/$($project.Id)/channels" -ApiKey $SourceData.OctopusApiKey -OctopusUrl $SourceData.OctopusUrl -SpaceId $SourceData.SpaceId
        $destinationChannels = Get-OctopusApiItemList -EndPoint "projects/$($destinationProject.Id)/channels" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId

        Copy-OctopusProjectChannels -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -destinationProject $destinationProject -sourceData $SourceData -destinationData $DestinationData
        Copy-OctopusProjectDeploymentProcess -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -destinationProject $destinationProject -sourceData $SourceData -destinationData $DestinationData 
        Copy-OctopusProjectRunbooks -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -destinationProject $destinationProject -sourceProject $project -destinationData $DestinationData -sourceData $SourceData            
        Copy-OctopusProjectVariables -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -destinationProject $destinationProject -sourceProject $project -destinationData $DestinationData -sourceData $SourceData -cloneScriptOptions $CloneScriptOptions -createdNewProject $createdNewProject        
    }
}