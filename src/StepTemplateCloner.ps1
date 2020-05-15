function Copy-OctopusStepTemplates
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.StepTemplates -itemType "Step Templates" -filters $cloneScriptOptions.StepTemplatesToClone

    foreach ($clonedItem in $filteredList)
    {
        Write-VerboseOutput "Cloning step template $($clonedItem.Name)"
        
        $matchingItem = Get-OctopusItemByName -ItemName $clonedItem.Name -ItemList $destinationData.StepTemplates       

        if ($null -ne $clonedItem.CommunityActionTemplateId -and $null -eq $matchingItem)
        {
            Write-GreenOutput "This is a step template which hasn't been install yet, pulling down from the interwebs"
            $destinationTemplate = Get-OctopusItemByName -ItemList $destinationData.CommunityActionTemplates -ItemName $clonedItem.Name            

            Save-OctopusApi -OctopusUrl $destinationData.OctopusUrl -SpaceId $null -EndPoint "/communityactiontemplates/$($destinationTemplate.Id)/installation/$($destinationData.SpaceId)" -ApiKey $destinationData.OctopusApiKey -Method POST
        }        
        elseif ($null -eq $clonedItem.CommunityActionTemplateId)
        {
            Write-GreenOutput "This is a custom step template following normal cloning logic"
            Copy-OctopusItem -ClonedItem $clonedItem -DestinationItemList $destinationData.StepTemplates -DestinationSpaceId $destinationData.SpaceId -ApiKey $destinationData.OctopusApiKey -EndPoint "actiontemplates" -ItemTypeName "Custom Step Template" -DestinationCanBeOverwritten $cloneScriptOptions.OverwriteExistingCustomStepTemplates -DestinationOctopusUrl $destinationData.OctopusUrl
        }                
    }

    Write-GreenOutput "Reloading step template list"
    
    $destinationData.StepTemplates = Get-OctopusStepTemplateList -SpaceId $($destinationData.SpaceId) -OctopusServerUrl $($destinationData.OctopusUrl) -ApiKey $($destinationData.OctopusApiKey)
}