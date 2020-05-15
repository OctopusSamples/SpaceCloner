. ($PSScriptRoot + ".\..\Core\Logging.ps1")
. ($PSScriptRoot + ".\..\Core\Util.ps1")

. ($PSScriptRoot + ".\..\DataAccess\OctopusDataAdapter.ps1")
. ($PSScriptRoot + ".\..\DataAccess\OctopusDataFactory.ps1")

. ($PSScriptRoot + ".\BasicCloner.ps1")

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
        $lifeCycleToClone = Copy-OctopusObject -ItemToCopy $lifecycle -ClearIdValue $false -SpaceId $null      

        foreach ($phase in $lifeCycleToClone.Phases)
        {
            $NewEnvironmentIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $phase.OptionalDeploymentTargets            
            $phase.OptionalDeploymentTargets = @($NewEnvironmentIds)

            $NewEnvironmentIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $phase.AutomaticDeploymentTargets            
            $phase.AutomaticDeploymentTargets = @($NewEnvironmentIds)
        }

        Copy-OctopusItem -ClonedItem $lifeCycleToClone -DestinationItemList $DestinationData.LifeCycleList -DestinationSpaceId $DestinationData.SpaceId -ApiKey $DestinationData.OctopusApiKey -EndPoint "lifecycles" -ItemTypeName "Lifecycle" -DestinationCanBeOverwritten $CloneScriptOptions.OverwriteExistingLifecyclesPhases -DestinationOctopusUrl $DestinationData.OctopusUrl
    }

    Write-GreenOutput "Reloading destination lifecycles"
    
    $destinationData.LifeCycleList = Get-OctopusLifeCycles -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}