. ($PSScriptRoot + ".\..\Core\Logging.ps1")
. ($PSScriptRoot + ".\..\Core\Util.ps1")

. ($PSScriptRoot + ".\..\DataAccess\OctopusDataAdapter.ps1")
. ($PSScriptRoot + ".\..\DataAccess\OctopusDataFactory.ps1")

. ($PSScriptRoot + ".\BasicCloner.ps1")

function Copy-OctopusProjectGroups
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.ProjectGroupList -itemType "Project Groups" -filters $cloneScriptOptions.ProjectGroupsToClone
    
    Copy-OctopusSimpleItems -SourceItemList $filteredList -DestinationItemList $destinationData.ProjectGroupList -EndPoint "projectgroups" -ApiKey $($destinationData.OctopusApiKey) -destinationSpaceId $destinationData.SpaceId -ItemTypeName "Project Groups" -DestinationCanBeOverwritten $false -DestinationOctopusUrl $destinationData.OctopusUrl

    Write-GreenOutput "Reloading destination project groups"
        
    $destinationData.ProjectGroupList = Get-ProjectGroups -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}