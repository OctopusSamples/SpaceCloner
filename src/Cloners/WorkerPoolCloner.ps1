. ($PSScriptRoot + ".\..\Core\Logging.ps1")
. ($PSScriptRoot + ".\..\Core\Util.ps1")

. ($PSScriptRoot + ".\..\DataAccess\OctopusDataAdapter.ps1")
. ($PSScriptRoot + ".\..\DataAccess\OctopusDataFactory.ps1")

. ($PSScriptRoot + ".\BasicCloner.ps1")

function Copy-OctopusWorkerPools
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    if ($sourceData.HasWorkers -eq $false -or $destinationData.HasWorkers -eq $false)
    {
        Write-YellowOutput "The source or destination Octopus instance doesn't have workers, skipping cloning workers"
        return
    }

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.WorkerPoolList -itemType "Worker Pool List" -filters $cloneScriptOptions.WorkerPoolsToClone
    
    Copy-OctopusSimpleItems -SourceItemList $filteredList -DestinationItemList $destinationData.WorkerPoolList -DestinationSpaceId $destinationData.SpaceId -ApiKey $destinationData.OctopusApiKey -EndPoint "WorkerPools" -ItemTypeName "Worker Pools" -DestinationCanBeOverwritten $false -DestinationOctopusUrl $DestinationData.OctopusUrl

    Write-GreenOutput "Reloading destination worker pool list"
    $destinationData.WorkerPoolList = Get-OctopusWorkerPoolList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}