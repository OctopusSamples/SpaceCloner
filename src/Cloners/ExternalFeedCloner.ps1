. ($PSScriptRoot + ".\..\Core\Logging.ps1")
. ($PSScriptRoot + ".\..\Core\Util.ps1")

. ($PSScriptRoot + ".\..\DataAccess\OctopusDataAdapter.ps1")
. ($PSScriptRoot + ".\..\DataAccess\OctopusDataFactory.ps1")

. ($PSScriptRoot + ".\BasicCloner.ps1")

function Copy-OctopusExternalFeeds
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.FeedList -itemType "Feeds" -filters $cloneScriptOptions.ExternalFeedsToClone

    $feedTypeFilteredList = @()
    
    foreach ($feed in $filteredList)
    {
        if ($feed.FeedType -eq "GitHub" -and $destinationData.HasGitHubFeedTypeSupport -eq $false)
        {
            Write-YellowOutput "The feed $($feed.Name) is of type $($feed.FeedType) which the destination doesn't support, skipping."
        }
        elseif ($feed.FeedType -eq "Helm" -and $destinationData.HasK8sSupport -eq $false)
        {
            Write-YellowOutput "The feed $($feed.Name) is of type $($feed.FeedType) which the destination doesn't support, skipping."
        }
        elseif ($feed.FeedType -eq "Maven" -and $destinationData.HasMavenFeedTypeSupport -eq $false)
        {
            Write-YellowOutput "The feed $($feed.Name) is of type $($feed.FeedType) which the destination doesn't support, skipping."
        }
        elseif ($feed.FeedType -eq "OctopusProject" -and $destinationData.HasOctopusProjectsFeedTypeSupport -eq $false)
        {
            Write-YellowOutput "The feed $($feed.Name) is of type $($feed.FeedType) which the destination doesn't support, skipping."
        }
        else
        {
            $feedTypeFilteredList += $feed
        }
    }
    
    Copy-OctopusSimpleItems -SourceItemList @($feedTypeFilteredList) -DestinationItemList $destinationData.FeedList -EndPoint "Feeds" -ApiKey $($destinationData.OctopusApiKey) -destinationSpaceId $($destinationData.SpaceId) -ItemTypeName "Feed" -DestinationCanBeOverwritten $false -DestinationOctopusUrl $destinationData.OctopusUrl

    Write-GreenOutput "Reloading destination feed list"
    
    $destinationData.FeedList = Get-OctopusFeedList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}