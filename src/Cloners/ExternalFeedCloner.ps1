function Copy-OctopusExternalFeeds
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.FeedList -itemType "Feeds" -filters $cloneScriptOptions.ExternalFeedsToClone    
    
    if ($filteredList.length -eq 0)
    {
        return
    }

    foreach ($feed in $filteredList)
    {
        Write-OctopusVerbose "Starting Clone of External Feed $($feed.Name)"
        
        $matchingItem = Get-OctopusItemByName -ItemName $feed.Name -ItemList $destinationData.FeedList
                
        If ($null -eq $matchingItem)
        {
            Write-OctopusVerbose "External Feed $($feed.Name) was not found in destination, creating new record."                 

            $copyOfItemToClone = Copy-OctopusObject -ItemToCopy $feed -SpaceId $destinationData.SpaceId -ClearIdValue $true    

            Save-OctopusApiItem -Item $copyOfItemToClone `
                -Endpoint "Feeds" `
                -ApiKey $destinationData.OctopusApiKey `
                -SpaceId $destinationData.SpaceId `
                -OctopusUrl $destinationData.OctopusUrl
        }
        else 
        {
            Write-OctopusVerbose "External Feed $($feed.Name) already exists, skipping."
        }
    }
        
    Write-OctopusSuccess "External Feeds successfully cloned, reloading destination list"    
    $destinationData.FeedList = Get-OctopusFeedList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}