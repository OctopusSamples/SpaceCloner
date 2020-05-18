function Copy-OctopusProjectRunbooks
{
    param(
        $sourceChannelList,
        $destinationChannelList,
        $destinationProject,        
        $sourceProject,
        $sourceData,
        $destinationData
    )

    if ($sourceData.HasRunbooks -eq $false -or $destinationData.HasRunbooks -eq $false)
    {
        Write-YellowOutput "The source or destination do not have runbooks, skipping the runbook clone process"
        return
    }

    $sourceRunbooks = Get-OctopusApiItemList -EndPoint "projects/$($sourceProject.Id)/runbooks" -ApiKey $sourcedata.OctopusApiKey -OctopusUrl $sourceData.OctopusUrl -SpaceId $sourceData.SpaceId
    $destinationRunbooks = Get-OctopusApiItemList -EndPoint "projects/$($destinationProject.Id)/runbooks" -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId

    foreach ($runbook in $sourceRunbooks)
    {
        $destinationRunbook = Get-OctopusItemByName -ItemList $destinationRunbooks -ItemName $runbook.Name
        
        if ($null -eq $destinationRunbook)
        {
            $runbookToClone = Copy-OctopusObject -ItemToCopy $runbook -SpaceId $destinationData.SpaceId -ClearIdValue $true
            
            $runbookToClone.ProjectId = $destinationProject.Id
            $runbookToClone.PublishedRunbookSnapshotId = $null
            $runbookToClone.RunbookProcessId = $null            

            Write-GreenOutput "The runbook $($runbook.Name) for $($destinationProject.Name) doesn't exist, creating it now"
            $destinationRunbook = Save-OctopusApiItem -Item $runbookToClone -Endpoint "runbooks" -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId            
        }
        
        $sourceRunbookProcess = Get-OctopusApi -EndPoint $runbook.Links.RunbookProcesses -ApiKey $sourcedata.OctopusApiKey -OctopusUrl $sourceData.OctopusUrl -SpaceId $null
        $destinationRunbookProcess = Get-OctopusApi -EndPoint $destinationRunbook.Links.RunbookProcesses -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $null

        Write-CleanUpOutput "Syncing deployment process for $($runbook.Name)"        
        $destinationRunbookProcess.Steps = @(Copy-OctopusDeploymentProcess -sourceChannelList $sourceChannelList -destinationChannelList $destinationChannelList -sourceData $sourceData -destinationData $destinationData -sourceDeploymentProcessSteps $sourceRunbookProcess.Steps -destinationDeploymentProcessSteps $destinationRunbookProcess.Steps)
            
        Save-OctopusApiItem -Item $destinationRunbookProcess -Endpoint "runbookProcesses" -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId
    }
}