function Copy-OctopusMachinePolicies
{
    param(
        $SourceData,
        $DestinationData,
        $CloneScriptOptions
    )

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.MachinePolicyList -itemType "Machine Policies" -filters $cloneScriptOptions.MachinePoliciesToClone

    foreach ($machinePolicy in $filteredList)
    {
        Write-GreenOutput "Starting clone of machine policy $($machinePolicy.Name)"

        $matchingItem = Get-OctopusItemByName -ItemName $machinePolicy.Name -ItemList $destinationData.MachinePolicyList         

        $machinePolicyToClone = Copy-OctopusObject -ItemToCopy $machinePolicy -ClearIdValue $true -SpaceId $destinationData.SpaceId  
        
        if ($null -ne $matchingItem)
        {
            $machinePolicyToClone.Id = $matchingItem.Id
        }

        Save-OctopusApiItem -Item $machinePolicyToClone `
                -Endpoint "machinepolicies" `
                -ApiKey $destinationData.OctopusApiKey `
                -SpaceId $destinationData.SpaceId `
                -OctopusUrl $destinationData.OctopusUrl
    }    

    Write-GreenOutput "Reloading destination machine policies"
    
    $destinationData.MachinePolicyList = Get-OctopusMachinePolicies -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}