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

    foreach ($workerPool in $filteredList)
    {                              
        Write-VerboseOutput "Starting Clone of Worker Pool $($workerPool.Name)"
        
        $matchingItem = Get-OctopusItemByName -ItemName $workerPool.Name -ItemList $destinationData.WorkerPoolList
                
        If ($null -eq $matchingItem)
        {            
            Write-GreenOutput "Worker Pool $($WorkerPool.Name) was not found in destination, creating new record."                                        

            $copyOfItemToClone = Copy-OctopusObject -ItemToCopy $workerpool -SpaceId $destinationData.SpaceId -ClearIdValue $true    

            Add-PropertyIfMissing -objectToTest $copyOfItemToClone -propertyName "WorkerPoolType" -propertyValue "StaticWorkerPool"                  

            Save-OctopusApiItem -Item $copyOfItemToClone `
                -Endpoint "projectgroups" `
                -ApiKey $destinationData.OctopusApiKey `
                -SpaceId $destinationData.SpaceId `
                -OctopusUrl $destinationData.OctopusUrl
        }
        else 
        {
            Write-GreenOutput "Worker Pool $($workerPool.Name) already exists in destination, skipping"    
        }
    }    

    Write-GreenOutput "Reloading destination worker pool list"
    $destinationData.WorkerPoolList = Get-OctopusWorkerPoolList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}