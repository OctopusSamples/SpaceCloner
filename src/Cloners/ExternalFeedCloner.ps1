function Copy-OctopusExternalFeeds
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.FeedList -itemType "Feeds" -filters $cloneScriptOptions.ExternalFeedsToClone    
    
    foreach ($feed in $filteredList)
    {
        if ((Get-OctopusExternalFeedSupportedOnDestination -feed $feed -destinationData $destinationData) -eq $false)
        {
            continue
        }

        Write-VerboseOutput "Starting Clone of External Feed $($feed.Name)"
        
        $matchingItem = Get-OctopusItemByName -ItemName $feed.Name -ItemList $destinationData.FeedList
                
        If ($null -eq $matchingItem)
        {
            Write-GreenOutput "External Feed $($feed.Name) was not found in destination, creating new record."                 

            $copyOfItemToClone = Copy-OctopusObject -ItemToCopy $feed -SpaceId $destinationData.SpaceId -ClearIdValue $true    

            Save-OctopusApiItem -Item $copyOfItemToClone `
                -Endpoint "Feeds" `
                -ApiKey $destinationData.OctopusApiKey `
                -SpaceId $destinationData.SpaceId `
                -OctopusUrl $destinationData.OctopusUrl
        }
        else 
        {
            Write-GreenOutput "External Feed $($feed.Name) already exists, skipping."
        }
    }
        
    Write-GreenOutput "Reloading destination feed list"    
    $destinationData.FeedList = Get-OctopusFeedList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}

function Get-OctopusExternalFeedSupportedOnDestination
{
    param (
        $feed,
        $destinationData)
    
    if ($feed.FeedType -eq "GitHub" -and $destinationData.HasGitHubFeedTypeSupport -eq $false)
    {
        Write-YellowOutput "The feed $($feed.Name) is of type $($feed.FeedType) which the destination doesn't support, skipping."
        return $false
    }
    
    if ($feed.FeedType -eq "Helm" -and $destinationData.HasK8sSupport -eq $false)
    {
        Write-YellowOutput "The feed $($feed.Name) is of type $($feed.FeedType) which the destination doesn't support, skipping."
        return $false
    }
    
    if ($feed.FeedType -eq "Maven" -and $destinationData.HasMavenFeedTypeSupport -eq $false)
    {
        Write-YellowOutput "The feed $($feed.Name) is of type $($feed.FeedType) which the destination doesn't support, skipping."
        return $false
    }
    
    if ($feed.FeedType -eq "OctopusProject" -and $destinationData.HasOctopusProjectsFeedTypeSupport -eq $false)
    {
        Write-YellowOutput "The feed $($feed.Name) is of type $($feed.FeedType) which the destination doesn't support, skipping."
        return $false
    }

    return $true
}