. ($PSScriptRoot + ".\..\Core\Logging.ps1")
. ($PSScriptRoot + ".\..\Core\Util.ps1")

. ($PSScriptRoot + ".\..\DataAccess\OctopusDataAdapter.ps1")
. ($PSScriptRoot + ".\..\DataAccess\OctopusDataFactory.ps1")

function Copy-OctopusSimpleItems
{
    param(
        $SourceItemList,
        $DestinationItemList,
        $DestinationSpaceId,                
        $ApiKey,
        $EndPoint,
        $ItemTypeName,
        $DestinationCanBeOverwritten,
        $DestinationOctopusUrl
    )

    foreach ($clonedItem in $SourceItemList)
    {
        Copy-OctopusItem -ClonedItem $clonedItem -DestinationSpaceId $DestinationSpaceId -ApiKey $ApiKey -EndPoint $EndPoint -DestinationItemList $DestinationItemList -ItemTypeName $ItemTypeName -DestinationCanBeOverwritten $DestinationCanBeOverwritten -DestinationOctopusUrl $DestinationOctopusUrl
    }
}

function Copy-OctopusItem
{
    param
    (
        $ClonedItem,
        $DestinationItemList,
        $DestinationSpaceId,        
        $ApiKey,
        $EndPoint,
        $ItemTypeName,
        $DestinationCanBeOverwritten,
        $DestinationOctopusUrl
    )

    Write-VerboseOutput "Cloning $ItemTypeName $($clonedItem.Name)"
        
    $matchingItem = Get-OctopusItemByName -ItemName $clonedItem.Name -ItemList $DestinationItemList
    
    $copyOfItemToClone = Copy-OctopusObject -ItemToCopy $ClonedItem -SpaceId $DestinationSpaceId -ClearIdValue $true    

    If ($null -eq $matchingItem)
    {
        Write-GreenOutput "$ItemTypeName $($clonedItem.Name) was not found in destination, creating new record."                                        
        Save-OctopusApiItem -Item $copyOfItemToClone -Endpoint $EndPoint -ApiKey $ApiKey -SpaceId $DestinationSpaceId -OctopusUrl $DestinationOctopusUrl
    }
    elseif ($DestinationCanBeOverwritten -eq $false)
    {
        Write-GreenOutput "The $ItemTypeName $($ClonedItem.Name) already exists. Skipping."
    }
    else
    {        
        Write-VerboseOutput "Overwriting $ItemTypeName $($clonedItem.Name) with data from source."
        $copyOfItemToClone.Id = $matchingItem.Id
        Save-OctopusApiItem -Item $copyOfItemToClone -Endpoint $EndPoint -ApiKey $ApiKey -SpaceId $DestinationSpaceId -OctopusUrl $DestinationOctopusUrl
    }    
}