function Copy-OctopusEnvironments
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.EnvironmentList -itemType "Environment" -filters $cloneScriptOptions.EnvironmentsToClone        
    
    Copy-OctopusSimpleItems -SourceItemList $filteredList -DestinationItemList $destinationData.EnvironmentList -DestinationSpaceId $destinationData.SpaceId -ApiKey $destinationData.OctopusApiKey -EndPoint "Environments" -ItemTypeName "Environment" -DestinationCanBeOverwritten $false -DestinationOctopusUrl $destinationData.OctopusUrl

    Write-GreenOutput "Reloading destination environment list"    
    $destinationData.EnvironmentList = Get-OctopusEnvironmentList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}
