function Copy-OctopusLibraryVariableSets
{
    param
    (
        $SourceData,
        $DestinationData,
        $cloneScriptOptions
    )

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.VariableSetList -itemType "Library Variable Sets" -filters $cloneScriptOptions.LibraryVariableSetsToClone

    foreach($sourceVariableSet in $filteredList)
    {
        Write-VerboseOutput "Starting clone of $($sourceVariableSet.Name)"

        $destinationVariableSet = Get-OctopusItemByName -ItemList $destinationData.VariableSetList -ItemName $sourceVariableSet.Name

        if ($null -eq $destinationVariableSet)
        {
            Write-GreenOutput "Variable Set $($sourceVariableSet.Name) was not found in destination, creating new base record."
            $copySourceVariableSet = Copy-OctopusObject -ItemToCopy $sourceVariableSet -ClearIdValue $true -SpaceId $destinationData.SpaceId                       
            $copySourceVariableSet.VariableSetId = $null

            $destinationVariableSet = Save-OctopusApi -EndPoint "libraryvariablesets" -ApiKey $($destinationData.OctopusApiKey) -Method POST -Item $copySourceVariableSet -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId
        }
        else
        {
            Write-GreenOutput "Variable Set $($sourceVariableSet.Name) already exists in destination."
        }

        Write-VerboseOutput "The variable set has been created, time to copy over the variables themselves"

        $sourceVariableSetVariables = Get-OctopusApi -EndPoint $sourceVariableSet.Links.Variables -ApiKey $sourceData.OctopusApiKey -SpaceId $null -OctopusUrl $SourceData.OctopusUrl 
        $destinationVariableSetVariables = Get-OctopusApi -EndPoint $destinationVariableSet.Links.Variables -ApiKey $destinationData.OctopusApiKey -SpaceId $null -OctopusUrl $DestinationData.OctopusUrl

        Write-CleanUpOutput "*****************Starting clone of variable set $($sourceVariableSet.Name)*****************"
        Copy-OctopusVariableSetValues -SourceVariableSetVariables $sourceVariableSetVariables -DestinationVariableSetVariables $destinationVariableSetVariables -SourceData $SourceData -DestinationData $DestinationData -SourceProjectData @{} -DestinationProjectData @{} -CloneScriptOptions $cloneScriptOptions
        Write-CleanUpOutput "*****************Ending clone of variable set $($sourceVariableSet.Name)*******************"
    }

    Write-GreenOutput "Reloading destination variable set list"
    
    $destinationData.VariableSetList = Get-OctopusLibrarySetList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}