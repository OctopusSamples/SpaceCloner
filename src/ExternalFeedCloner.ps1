function Copy-OctopusExternalFeeds
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.FeedList -itemType "Feeds" -filters $cloneScriptOptions.ExternalFeedsToClone
    
    Copy-OctopusSimpleItems -SourceItemList $filteredList -DestinationItemList $destinationData.FeedList -EndPoint "Feeds" -ApiKey $($destinationData.OctopusApiKey) -destinationSpaceId $($destinationData.SpaceId) -ItemTypeName "Feed" -DestinationCanBeOverwritten $false -DestinationOctopusUrl $destinationData.OctopusUrl

    Write-GreenOutput "Reloading destination feed list"
    
    $destinationData.FeedList = Get-OctopusFeedList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}