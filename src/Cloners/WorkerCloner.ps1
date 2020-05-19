function Copy-OctopusWorkers
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
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.WorkerList -itemType "Worker List" -filters $cloneScriptOptions.WorkersToClone

    if ($sourceData.OctopusUrl -ne $destinationData.OctopusUrl -and $filteredList.length -gt 0)
    {
        Write-RedOutput "You are cloning workers from one instance to another, the server thumbprints will not be accepted by the workers until you run Tentacle.exe configure --trust='your server thumbprint'"
    }

    foreach ($worker in $filteredList)
    {                              
        Write-VerboseOutput "Starting Clone of Worker $($worker.Name)"

        if ($worker.Endpoint.CommunicationStyle -eq "TentacleActive")
        {
            Write-YellowOutput "The worker $($worker.Name) is a polling tentacle, this script cannot clone polling tentacles, skipping."
            continue
        }
        
        $matchingItem = Get-OctopusItemByName -ItemName $worker.Name -ItemList $destinationData.WorkerList
                
        If ($null -eq $matchingItem)
        {            
            Write-GreenOutput "Worker $($worker.Name) was not found in destination, creating new record."                                        

            $copyOfItemToClone = Copy-OctopusObject -ItemToCopy $worker -SpaceId $destinationData.SpaceId -ClearIdValue $true    

            $copyOfItemToClone.WorkerPoolIds = @(Convert-SourceIdListToDestinationIdList -SourceList $sourceData.WorkerPoolList -DestinationList $destinationData.WorkerPoolList -IdList $worker.WorkerPoolIds)
            $copyOfItemToClone.MachinePolicyId = Convert-SourceIdToDestinationId -SourceList $sourceData.MachinePolicyList -DestinationList $destinationData.MachinePolicyList -IdValue $worker.MachinePolicyId
            $copyOfItemToClone.Status = "Unknown"
            $copyOfItemToClone.HealthStatus = "Unknown"
            $copyOfItemToClone.StatusSummary = ""
            $copyOfItemToClone.IsInProcess = $false

            Save-OctopusApiItem -Item $copyOfItemToClone `
                -Endpoint "workers" `
                -ApiKey $destinationData.OctopusApiKey `
                -SpaceId $destinationData.SpaceId `
                -OctopusUrl $destinationData.OctopusUrl
        }
        else 
        {
            Write-GreenOutput "Worker $($worker.Name) already exists in destination, skipping"    
        }
    }    

    Write-GreenOutput "Reloading destination Worker list"
    $destinationData.WorkerList = Get-OctopusWorkers -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}