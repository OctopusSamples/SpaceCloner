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
    $OverwriteExistingLifecyclesPhases   
)

. ($PSScriptRoot + ".\src\AccountCloner.ps1")
. ($PSScriptRoot + ".\src\BasicCloner.ps1")
. ($PSScriptRoot + ".\src\EnvironmentCloner.ps1")
. ($PSScriptRoot + ".\src\ExternalFeedCloner.ps1")
. ($PSScriptRoot + ".\src\LibraryVariableSetCloner.ps1")
. ($PSScriptRoot + ".\src\LifecycleCloner.ps1")
. ($PSScriptRoot + ".\src\Logging.ps1")
. ($PSScriptRoot + ".\src\OctopusDataAdapter.ps1")
. ($PSScriptRoot + ".\src\OctopusDataFactory.ps1")
. ($PSScriptRoot + ".\src\ProcessCloner.ps1")
. ($PSScriptRoot + ".\src\ProjectCloner.ps1")
. ($PSScriptRoot + ".\src\ProjectGroupCloner.ps1")
. ($PSScriptRoot + ".\src\StepTemplateCloner.ps1")
. ($PSScriptRoot + ".\src\TenantCloner.ps1")
. ($PSScriptRoot + ".\src\TenantTagSetCloner.ps1")
. ($PSScriptRoot + ".\src\Util.ps1")
. ($PSScriptRoot + ".\src\VariableSetValuesCloner.ps1")
. ($PSScriptRoot + ".\src\WorkerPoolCloner.ps1")

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
}

$sourceData = Get-OctopusData -octopusUrl $SourceOctopusUrl -octopusApiKey $SourceOctopusApiKey -spaceName $SourceSpaceName
$destinationData = Get-OctopusData -octopusUrl $DestinationOctopusUrl -octopusApiKey $DestinationOctopusApiKey -spaceName $DestinationSpaceName

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