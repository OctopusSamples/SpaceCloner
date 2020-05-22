function Copy-OctopusEnvironments
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.EnvironmentList -itemType "Environment" -filters $cloneScriptOptions.EnvironmentsToClone        
    
    if ($filteredList.length -eq 0)
    {
        return
    }

    foreach ($environment in $filteredList)
    {
        Write-OctopusVerbose "Starting clone of Environment $($environment.Name)"
        
        $matchingItem = Get-OctopusItemByName -ItemName $environment.Name -ItemList $destinationData.EnvironmentList                

        If ($null -eq $matchingItem)
        {
            Write-OctopusVerbose "Environment $($environment.Name) was not found in destination, creating new record."                    

            $copyOfItemToClone = Copy-OctopusObject -ItemToCopy $environment -SpaceId $destinationData.SpaceId -ClearIdValue $true    

            Save-OctopusApiItem -Item $copyOfItemToClone `
                -Endpoint "Environments" `
                -ApiKey $destinationData.OctopusApiKey `
                -SpaceId $destinationData.SpaceId `
                -OctopusUrl $destinationData.OctopusUrl
        }
        else 
        {
            Write-OctopusVerbose "Environment $($environment.Name) already exists in destination, skipping"    
        }
    }    

    Write-OctopusSuccess "Environments successfully cloned, reloading destination list"    
    $destinationData.EnvironmentList = Get-OctopusEnvironmentList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}
