function Copy-OctopusStepTemplates
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.StepTemplates -itemType "Step Templates" -filters $cloneScriptOptions.StepTemplatesToClone

    foreach ($stepTemplate in $filteredList)
    {
        Write-VerboseOutput "Starting Clone of step template $($stepTemplate.Name)"
        
        $matchingItem = Get-OctopusItemByName -ItemName $stepTemplate.Name -ItemList $destinationData.StepTemplates
        
        Write-Host "The matching item is: $matchingItem"

        if ($null -ne $stepTemplate.CommunityActionTemplateId -and $null -eq $matchingItem)
        {
            Write-GreenOutput "The step template $($stepTemplate.Name) is a community step template and it hasn't been installed yet, installing"
            $destinationTemplate = Get-OctopusItemByName -ItemList $destinationData.CommunityActionTemplates -ItemName $stepTemplate.Name            

            Save-OctopusApi -OctopusUrl $destinationData.OctopusUrl -SpaceId $null -EndPoint "/communityactiontemplates/$($destinationTemplate.Id)/installation/$($destinationData.SpaceId)" -ApiKey $destinationData.OctopusApiKey -Method POST
        }        
        elseif ($null -eq $stepTemplate.CommunityActionTemplateId -and $null -ne $matchingItem -and $cloneScriptOptions.OverwriteExistingCustomStepTemplates -eq $false)
        {
            Write-GreenOutput "The step template $($stepTemplate.Name) already exists on the destination machine and you elected to skip existing step templates, skipping"                        
        }                
        elseif ($null -eq $stepTemplate.CommunityActionTemplateId) 
        {
            Write-GreenOutput "Saving $($stepTemplate.Name) to destination."

            $stepTemplateToClone = Copy-OctopusObject -ItemToCopy $stepTemplate -SpaceId $destinationData.SpaceId -ClearIdValue $true    
            if ($null -ne $matchingItem)
            {
                $stepTemplateToClone.Id = $matchingItem.Id
            }

            Save-OctopusApiItem -Item $stepTemplateToClone `
                -Endpoint "actiontemplates" `
                -ApiKey $destinationData.OctopusApiKey `
                -SpaceId $destinationData.SpaceId `
                -OctopusUrl $destinationData.OctopusUrl
        }        
    }

    Write-GreenOutput "Reloading step template list"    
    $destinationData.StepTemplates = Get-OctopusStepTemplateList -SpaceId $($destinationData.SpaceId) -OctopusServerUrl $($destinationData.OctopusUrl) -ApiKey $($destinationData.OctopusApiKey)
}