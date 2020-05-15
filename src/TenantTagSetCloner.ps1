function Copy-OctopusTenantTags
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.TenantTagList -itemType "Tenant Tags" -filters $cloneScriptOptions.TenantTagsToClone
    
    Copy-OctopusSimpleItems -SourceItemList $filteredList -DestinationItemList $destinationData.TenantTagList -EndPoint "TagSets" -ApiKey $($destinationData.OctopusApiKey) -destinationSpaceId $($destinationData.SpaceId) -ItemTypeName "Tenant Tag Set" -DestinationCanBeOverwritten $true -DestinationOctopusUrl $destinationData.OctopusUrl

    Write-GreenOutput "Reloading destination Tenant Tag Set"
    
    $destinationData.TenantTagList = Get-OctopusTenantTagSet -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}