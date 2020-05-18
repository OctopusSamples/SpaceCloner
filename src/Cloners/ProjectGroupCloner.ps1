function Copy-OctopusProjectGroups
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.ProjectGroupList -itemType "Project Groups" -filters $cloneScriptOptions.ProjectGroupsToClone
    
    foreach ($projectGroup in $filteredList)
    {
        Write-VerboseOutput "Starting Clone Of Project Group $($projectGroup.Name)"
        
        $matchingItem = Get-OctopusItemByName -ItemName $projectGroup.Name -ItemList $destinationData.ProjectGroupList                

        If ($null -eq $matchingItem)
        {
            Write-GreenOutput "Project Group $($projectGroup.Name) was not found in destination, creating new record."  

            $copyOfItemToClone = Copy-OctopusObject -ItemToCopy $projectGroup -SpaceId $destinationData.SpaceId -ClearIdValue $true                                          

            Save-OctopusApiItem -Item $copyOfItemToClone `
                -Endpoint "projectgroups" `
                -ApiKey $destinationData.OctopusApiKey `
                -SpaceId $destinationData.SpaceId `
                -OctopusUrl $destinationData.OctopusUrl
        }
        else 
        {
            Write-GreenOutput "Project Group $($projectGroup.Name) already exists in destination, skipping"    
        }
    } 
    
    Write-GreenOutput "Reloading destination project groups"        
    $destinationData.ProjectGroupList = Get-ProjectGroups -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}