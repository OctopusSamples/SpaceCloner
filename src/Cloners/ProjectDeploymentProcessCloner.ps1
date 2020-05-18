function Copy-OctopusProjectDeploymentProcess
{
    param(
        $sourceChannelList,
        $destinationChannelList,
        $sourceProject,
        $destinationProject,        
        $sourceData,
        $destinationData
    )

    Write-GreenOutput "Syncing deployment process for $($destinationProject.Name)"
    $sourceDeploymentProcess = Get-OctopusApi -EndPoint $sourceProject.Links.DeploymentProcess -ApiKey $SourceData.OctopusApiKey -OctopusUrl $sourceData.OctopusUrl -SpaceId $null
    $destinationDeploymentProcess = Get-OctopusApi -EndPoint $destinationProject.Links.DeploymentProcess -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $null
    
    $destinationDeploymentProcess.Steps = @(Copy-OctopusDeploymentProcess -sourceChannelList $sourceChannelList -destinationChannelList $destinationChannelList -sourceData $sourceData -destinationData $destinationData -sourceDeploymentProcessSteps $sourceDeploymentProcess.Steps -destinationDeploymentProcessSteps $destinationDeploymentProcess.Steps)

    Save-OctopusApiItem -Item $destinationDeploymentProcess -Endpoint "deploymentprocesses" -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId
}