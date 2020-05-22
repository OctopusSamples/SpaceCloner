function Copy-OctopusProjectGroups
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.ProjectGroupList -itemType "Project Groups" -filters $cloneScriptOptions.ProjectGroupsToClone
    
    if ($filteredList.length -eq 0)
    {
        return
    }
    
    foreach ($projectGroup in $filteredList)
    {
        Write-OctopusVerbose "Starting Clone Of Project Group $($projectGroup.Name)"
        
        $matchingItem = Get-OctopusItemByName -ItemName $projectGroup.Name -ItemList $destinationData.ProjectGroupList                

        If ($null -eq $matchingItem)
        {
            Write-OctopusVerbose "Project Group $($projectGroup.Name) was not found in destination, creating new record."  

            $copyOfItemToClone = Copy-OctopusObject -ItemToCopy $projectGroup -SpaceId $destinationData.SpaceId -ClearIdValue $true                                          

            Save-OctopusApiItem -Item $copyOfItemToClone `
                -Endpoint "projectgroups" `
                -ApiKey $destinationData.OctopusApiKey `
                -SpaceId $destinationData.SpaceId `
                -OctopusUrl $destinationData.OctopusUrl
        }
        else 
        {
            Write-OctopusVerbose "Project Group $($projectGroup.Name) already exists in destination, skipping"    
        }
    } 
    
    Write-OctopusSuccess "Project Groups successfully cloned, reloading destination list"
    $destinationData.ProjectGroupList = Get-ProjectGroupList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}