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

        Write-OctopusPostCloneCleanUp "*****************Starting variable clone for $($destinationProject.Name)*******************"

        Copy-OctopusVariableSetValues -SourceVariableSetVariables $sourceVariableSetVariables -DestinationVariableSetVariables $destinationVariableSetVariables -SourceData $SourceData -DestinationData $DestinationData -SourceProjectData $SourceProjectData -DestinationProjectData $DestinationProjectData -CloneScriptOptions $cloneScriptOptions

        Write-OctopusPostCloneCleanUp "*****************Ended variable clone for $($destinationProject.Name)**********************"
    }
}