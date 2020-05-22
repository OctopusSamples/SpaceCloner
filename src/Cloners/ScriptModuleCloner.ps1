function Copy-OctopusScriptModules
{
    param
    (
        $SourceData,
        $DestinationData,
        $cloneScriptOptions
    )

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.ScriptModuleList -itemType "Script Modules" -filters $cloneScriptOptions.ScriptModulesToClone

    if ($filteredList.length -eq 0)
    {
        return
    }

    Write-OctopusVerbose "Getting a clone of the script options so we can always update the module text"
    $newCloneScriptOptions = Copy-OctopusObject -ItemToCopy $cloneScriptOptions -ClearIdValue $false -SpaceId $null
    $newCloneScriptOptions.OverwriteExistingVariables = $true

    foreach($scriptModule in $filteredList)
    {
        Write-OctopusVerbose "Starting clone of $($scriptModule.Name)"

        $destinationVariableSet = Get-OctopusItemByName -ItemList $destinationData.ScriptModuleList -ItemName $scriptModule.Name

        if ($null -eq $destinationVariableSet)
        {
            Write-OctopusVerbose "Script Module Variable Set $($scriptModule.Name) was not found in destination, creating new base record."
            $copyscriptModule = Copy-OctopusObject -ItemToCopy $scriptModule -ClearIdValue $true -SpaceId $destinationData.SpaceId                       
            $copyscriptModule.VariableSetId = $null

            $destinationVariableSet = Save-OctopusApi -EndPoint "libraryvariablesets" -ApiKey $($destinationData.OctopusApiKey) -Method POST -Item $copyscriptModule -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId
        }
        else
        {
            Write-OctopusVerbose "Script Module Variable Set $($scriptModule.Name) already exists in destination."
        }
        
        Write-OctopusVerbose "The script module variable set has been created, time to copy over the script module itself"

        $scriptModuleVariables = Get-OctopusApi -EndPoint $scriptModule.Links.Variables -ApiKey $sourceData.OctopusApiKey -SpaceId $null -OctopusUrl $SourceData.OctopusUrl 
        $destinationVariableSetVariables = Get-OctopusApi -EndPoint $destinationVariableSet.Links.Variables -ApiKey $destinationData.OctopusApiKey -SpaceId $null -OctopusUrl $DestinationData.OctopusUrl        

        Write-OctopusPostCloneCleanUp "*****************Starting clone of script module $($scriptModule.Name)*****************"
        Copy-OctopusVariableSetValues -SourceVariableSetVariables $scriptModuleVariables -DestinationVariableSetVariables $destinationVariableSetVariables -SourceData $SourceData -DestinationData $DestinationData -SourceProjectData @{} -DestinationProjectData @{} -CloneScriptOptions $newCloneScriptOptions
        Write-OctopusPostCloneCleanUp "*****************Ending clone of script module $($scriptModule.Name)*******************"
    }

    Write-OctopusSuccess "Script Modules successfully cloned, reloading destination list"    
    $destinationData.ScriptModuleList = Get-OctopusScriptModules -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}