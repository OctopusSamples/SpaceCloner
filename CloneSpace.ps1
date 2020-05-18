param (
    $SourceOctopusUrl,
    $SourceOctopusApiKey,
    $SourceSpaceName,
    $DestinationOctopusUrl,
    $DestinationOctopusApiKey,
    $DestinationSpaceName,
    $VerboseLogging,
    $EnvironmentsToClone,
    $WorkerPoolsToClone,
    $ProjectGroupsToClone, 
    $TenantTagsToClone,
    $ExternalFeedsToClone,
    $StepTemplatesToClone,
    $InfrastructureAccountsToClone,
    $LibraryVariableSetsToClone,
    $LifeCyclesToClone,    
    $ProjectsToClone,
    $TenantsToClone,
    $OverwriteExistingVariables,
    $AddAdditionalVariableValuesOnExistingVariableSets,
    $OverwriteExistingCustomStepTemplates,
    $OverwriteExistingLifecyclesPhases,
    $CloneProjectRunbooks   
)

. ($PSScriptRoot + ".\src\Core\Logging.ps1")
. ($PSScriptRoot + ".\src\Core\Util.ps1")

. ($PSScriptRoot + ".\src\DataAccess\OctopusDataAdapter.ps1")
. ($PSScriptRoot + ".\src\DataAccess\OctopusDataFactory.ps1")

. ($PSScriptRoot + ".\src\Cloners\AccountCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\ActionCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\EnvironmentCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\ExternalFeedCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\LibraryVariableSetCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\LifecycleCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\ProcessCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\ProjectChannelCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\ProjectCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\ProjectDeploymentProcessCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\ProjectGroupCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\ProjectRunbookCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\ProjectVariableCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\StepTemplateCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\TenantCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\TenantTagSetCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\VariableSetValuesCloner.ps1")
. ($PSScriptRoot + ".\src\Cloners\WorkerPoolCloner.ps1")

Clear-Host
$ErrorActionPreference = "Stop"

if ($null -eq $OverwriteExistingVariables)
{
    $OverwriteExistingVariables = $false
}

if ($null -eq $AddAdditionalVariableValuesOnExistingVariableSets)
{
    $AddAdditionalVariableValuesOnExistingVariableSets = $false
}

if ($null -eq $OverwriteExistingCustomStepTemplates)
{
    $OverwriteExistingCustomStepTemplates = $false
}

if ($null -eq $OverwriteExistingLifecyclesPhases)
{
    $OverwriteExistingLifecyclesPhases = $false
}

if ($null -eq $CloneProjectRunbooks)
{
    $CloneProjectRunbooks = $true
}

$CloneScriptOptions = @{
    EnvironmentsToClone = $EnvironmentsToClone; 
    WorkerPoolsToClone = $WorkerPoolsToClone; 
    ProjectGroupsToClone = $ProjectGroupsToClone;
    TenantTagsToClone = $TenantTagsToClone;
    ExternalFeedsToClone = $ExternalFeedsToClone;
    StepTemplatesToClone = $StepTemplatesToClone;
    InfrastructureAccountsToClone = $InfrastructureAccountsToClone;
    LibraryVariableSetsToClone = $LibraryVariableSetsToClone;
    LifeCyclesToClone = $LifeCyclesToClone;
    ProjectsToClone = $ProjectsToClone;
    OverwriteExistingVariables = $OverwriteExistingVariables;
    AddAdditionalVariableValuesOnExistingVariableSets = $AddAdditionalVariableValuesOnExistingVariableSets;
    OverwriteExistingCustomStepTemplates = $OverwriteExistingCustomStepTemplates;
    OverwriteExistingLifecyclesPhases = $OverwriteExistingLifecyclesPhases;
    TenantsToClone = $TenantsToClone;
    CloneProjectRunbooks = CloneProjectRunbooks;
}

$sourceData = Get-OctopusData -octopusUrl $SourceOctopusUrl -octopusApiKey $SourceOctopusApiKey -spaceName $SourceSpaceName
$destinationData = Get-OctopusData -octopusUrl $DestinationOctopusUrl -octopusApiKey $DestinationOctopusApiKey -spaceName $DestinationSpaceName

if ($sourceData.MajorVersion -ne $destinationData.MajorVersion -or $sourceData.MinorVersion -ne $sourceData.MinorVersion)
{
    Throw "The source $($sourceData.OctopusUrl) is on version $($sourceData.MajorVersion).$($sourceData.MinorVersion).x while the destination $($destinationData.OctopusUrl) is on version $($destinationData.MajorVersion).$($DestinationData.MinorVersion).x.  Nothing good will come of this clone.  Please upgrade the source or destination to match and try again."    
}

Copy-OctopusEnvironments -sourceData $sourceData -destinationData $destinationData -cloneScriptOptions $CloneScriptOptions
Copy-OctopusWorkerPools -sourceData $sourceData -destinationData $destinationData -cloneScriptOptions $CloneScriptOptions
Copy-OctopusProjectGroups -sourceData $sourceData -destinationData $destinationData -cloneScriptOptions $CloneScriptOptions
Copy-OctopusExternalFeeds -sourceData $sourceData -destinationData $destinationData -cloneScriptOptions $CloneScriptOptions
Copy-OctopusTenantTags -sourceData $sourceData -destinationData $destinationData -cloneScriptOptions $CloneScriptOptions
Copy-OctopusStepTemplates -sourceData $sourceData -destinationData $destinationData -cloneScriptOptions $CloneScriptOptions
Copy-OctopusInfrastructureAccounts -SourceData $sourceData -DestinationData $destinationData -CloneScriptOptions $CloneScriptOptions
Copy-OctopusLibraryVariableSets -SourceData $sourceData -DestinationData $destinationData  -cloneScriptOptions $CloneScriptOptions
Copy-OctopusLifecycles -sourceData $sourceData -destinationData $destinationData -cloneScriptOptions $CloneScriptOptions
Copy-OctopusProjects -SourceData $sourceData -DestinationData $destinationData -CloneScriptOptions $CloneScriptOptions
Copy-OctopusTenants -sourceData $sourceData -destinationData $destinationData -CloneScriptOptions $CloneScriptOptions

Write-GreenOutput "The script to clone $SourceSpaceName from $SourceOctopusUrl to $DestinationSpaceName in $DestinationOctopusUrl has completed"