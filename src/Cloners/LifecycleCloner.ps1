function Copy-OctopusLifecycles
{
    param(
        $SourceData,
        $DestinationData,
        $CloneScriptOptions
    )

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.LifeCycleList -itemType "Lifecycles" -filters $cloneScriptOptions.LifeCyclesToClone

    foreach ($lifecycle in $filteredList)
    {
        Write-GreenOutput "Starting clone of Lifecycle $($lifecycle.Name)"

        $matchingItem = Get-OctopusItemByName -ItemName $lifecycle.Name -ItemList $destinationData.LifeCycleList   

        if ($null -ne $matchingItem -and $CloneScriptOptions.OverwriteExistingLifecyclesPhases -eq $false)             
        {
            Write-GreenOutput "Lifecycle already exists and you selected not to overwrite phases, skipping"
            continue
        }        

        $lifeCycleToClone = Copy-OctopusObject -ItemToCopy $lifecycle -ClearIdValue $true -SpaceId $null  
        
        if ($null -ne $matchingItem)
        {
            $lifeCycleToClone.Id = $matchingItem.Id
        }

        foreach ($phase in $lifeCycleToClone.Phases)
        {            
            $phase.OptionalDeploymentTargets = @(Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $phase.OptionalDeploymentTargets)
            $phase.AutomaticDeploymentTargets = @(Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $phase.AutomaticDeploymentTargets)
        }

        Save-OctopusApiItem -Item $lifeCycleToClone `
                -Endpoint "lifecycles" `
                -ApiKey $destinationData.OctopusApiKey `
                -SpaceId $destinationData.SpaceId `
                -OctopusUrl $destinationData.OctopusUrl
    }    

    Write-GreenOutput "Reloading destination lifecycles"
    
    $destinationData.LifeCycleList = Get-OctopusLifeCycles -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}