function Get-OctopusSpaceList
{
    param (
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "spaces?skip=0&take=1000" -ApiKey $ApiKey -SpaceId $null -OctopusUrl $OctopusServerUrl
}

Function Get-OctopusProjectList
{
    param (        
        $SpaceId,        
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "Projects?skip=0&take=1000" -ApiKey $ApiKey  -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusEnvironmentList
{
    param (        
        $SpaceId,        
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "Environments?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusLibrarySetList
{
    param (
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )
    
    return Get-OctopusApiItemList -EndPoint "libraryvariablesets?skip=0&take=1000&contentType=Variables" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusScriptModuleList
{
    param (
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )
    
    return Get-OctopusApiItemList -EndPoint "libraryvariablesets?skip=0&take=1000&contentType=ScriptModule" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusLibrarySetVariables
{
    param(
        $VariableSetId,
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )
    
    return Get-OctopusApiItemList -EndPoint "variables/$VariableSetId" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusStepTemplateList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "actiontemplates?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusProjectRunBookList
{
    param(
        $ProjectId,
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "projects/$ProjectId/runbooks?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusRunbookProcess
{
    param(
        $RunbookProcessId,
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "runbookProcesses/$RunbookProcessId" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusWorkerPoolList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey,
        $HasWorkers
    )

    if ($null -eq $HasWorkers -or $HasWorkers -eq $true)
    {
        return Get-OctopusApiItemList -EndPoint "workerpools?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
    }
    
    return @()
}

Function Get-OctopusFeedList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "feeds?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusInfrastructureAccountList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "accounts?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

function Get-OctopusCommunityActionTemplateList
{
    param(
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "communityactiontemplates?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $null
}

Function Get-OctopusTenantTagSetList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "tagsets?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusLifeCycleList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "lifecycles?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-ProjectGroupList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "projectgroups?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusTenantList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "tenants?skip=0&take=10000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusMachinePolicyList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "machinepolicies?skip=0&take=10000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusWorkerList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "workers?skip=0&take=10000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusTargetList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "machines?skip=0&take=10000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusTeamList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "teams?spaces=$spaceId&includeSystem=true" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $null
}

Function Get-OctopusUserList
{
    param(        
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "users?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $null
}

Function Get-OctopusUserRoleList
{
    param(        
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "usersroles?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $null
}

function Get-OctopusSpaceId
{
    param(
        $octopusUrl,
        $octopusApiKey,
        $hasSpaces
    )

    if ($hasSpaces -eq $true)
    {                
        Write-OctopusVerbose "Getting Space Information from $octopusUrl"
        $SpaceList = Get-OctopusSpaceList -OctopusServerUrl $octopusUrl -ApiKey $octopusApiKey
        $Space = Get-OctopusItemByName -ItemList $SpaceList -ItemName $spaceName

        if ($null -eq $Space)
        {
            Throw "Unable to find space $spaceName on $octopusUrl please confirm it exists and try again."
        }

        return $Space.Id        
    }
    else
    {
        return $null
    }
}

function Get-OctopusProjectChannelList
{
    param(
        $project,
        $octopusUrl,
        $ApiKey,
        $spaceId
    )

    return Get-OctopusApiItemList -EndPoint "projects/$($project.Id)/channels" -ApiKey $ApiKey -OctopusUrl $OctopusUrl -SpaceId $SpaceId
}

function Get-OctopusProjectDeploymentProcess
{
    param(
        $project,
        $octopusUrl,
        $ApiKey
    )

    return Get-OctopusApi -EndPoint $project.Links.DeploymentProcess -ApiKey $ApiKey -OctopusUrl $OctopusUrl -SpaceId $null
}

function Get-OctopusProjectRunbookList
{
    param(
        $project,
        $octopusUrl,
        $ApiKey,
        $spaceId
    )

    return Get-OctopusApiItemList -EndPoint "projects/$($project.Id)/runbooks" -ApiKey $ApiKey -OctopusUrl $OctopusUrl -SpaceId $SpaceId
}

function Get-OctopusRunbookProcess
{
    param(
        $runbook,
        $octopusUrl,
        $ApiKey
    )

    return Get-OctopusApi -EndPoint $runbook.Links.RunbookProcesses -ApiKey $ApiKey -OctopusUrl $OctopusUrl -SpaceId $null
}

function Get-OctopusTeamScopedUserRoleList
{
    param(
        $team,
        $octopusUrl,
        $ApiKey        
    )

    return Get-OctopusApiItemList -EndPoint "teams/$($team.Id)/scopeduserroles?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusUrl
}

function Save-OctopusAccount
{
    param(
        $account,
        $destinationData
    )

    return Save-OctopusApiItem -Item $account -Endpoint "accounts" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusEnvironment
{
    param(
        $environment,
        $destinationData
    )

    return Save-OctopusApiItem -Item $environment -Endpoint "Environments" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusExternalFeed
{
    param(
        $externalFeed,
        $destinationData
    )

    return Save-OctopusApiItem -Item $externalFeed -Endpoint "Feeds" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusLifecycle
{
    param(
        $lifecycle,
        $destinationData
    )

    return Save-OctopusApiItem -Item $lifecycle -Endpoint "lifecycles" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusMachinePolicy
{
    param(
        $machinePolicy,
        $destinationData
    )

    return Save-OctopusApiItem -Item $machinePolicy -Endpoint "machinepolicies" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusProjectChannel
{
    param(
        $projectChannel,
        $destinationData
    )

    return Save-OctopusApiItem -Item $projectChannel -Endpoint "channels" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusProject
{
    param(
        $project,
        $destinationData
    )

    return Save-OctopusApiItem -Item $project -Endpoint "projects" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusProjectDeploymentProcess
{
    param(
        $deploymentProcess,
        $destinationData
    )

    return Save-OctopusApiItem -Item $deploymentProcess -Endpoint "deploymentprocesses" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusProjectGroup
{
    param(
        $projectGroup,
        $destinationData
    )

    return Save-OctopusApiItem -Item $projectGroup -Endpoint "projectgroups" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusProjectRunbook
{
    param(
        $runbook,
        $destinationData
    )

    return Save-OctopusApiItem -Item $runbook -Endpoint "runbooks" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusProjectRunbookProcess
{
    param(
        $runbookProcess,
        $destinationData
    )

    return Save-OctopusApiItem -Item $runbookProcess -Endpoint "runbookProcesses" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusStepTemplate
{
    param(
        $stepTemplate,
        $destinationData
    )

    return Save-OctopusApiItem -Item $stepTemplate -Endpoint "actiontemplates" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusTarget
{
    param(
        $target,
        $destinationData
    )

    return Save-OctopusApiItem -Item $target -Endpoint "machines" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusTeam
{
    param(
        $team,
        $destinationData
    )

    return Save-OctopusApiItem -Item $team -Endpoint "teams" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $null            
}

function Save-OctopusTeamScopedRoles
{
    param(
        $teamScopedUserRoles,
        $destinationData
    )

    return Save-OctopusApiItem -Item $teamScopedUserRoles -Endpoint "scopeduserroles" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $null            
}

function Save-OctopusTenant
{
    param(
        $tenant,
        $destinationData
    )

    return Save-OctopusApiItem -Item $tenant -Endpoint "tenants" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusTenantTagSet
{
    param(
        $tenantTagSet,
        $destinationData
    )

    return Save-OctopusApiItem -Item $tenantTagSet -Endpoint "TagSets" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusWorker
{
    param(
        $worker,
        $destinationData
    )

    return Save-OctopusApiItem -Item $worker -Endpoint "Workers" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusWorkerPool
{
    param(
        $workerPool,
        $destinationData
    )

    return Save-OctopusApiItem -Item $workerPool -Endpoint "workerpools" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
}

function Save-OctopusVariableSet
{
    param(
        $libraryVariableSet,
        $destinationData
    )

    return Save-OctopusApi -EndPoint "libraryvariablesets" -ApiKey $destinationData.OctopusApiKey -Method POST -Item $libraryVariableSet -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId
}

function Save-OctopusVariableSetVariables
{
    param(
        $libraryVariableSetVariables,
        $destinationData
    )

    return Save-OctopusApi -EndPoint $libraryVariableSetVariables.Links.Self -ApiKey $destinationData.OctopusApiKey -Method "PUT" -Item $DestinationVariableSetVariables -OctopusUrl $DestinationData.OctopusUrl -SpaceId $null
}

function Save-OctopusCommunityStepTemplate
{
    param(
        $communityStepTemplate,
        $destinationData
    )

    return Save-OctopusApi -OctopusUrl $destinationData.OctopusUrl -SpaceId $null -EndPoint "/communityactiontemplates/$($communityStepTemplate.Id)/installation/$($destinationData.SpaceId)" -ApiKey $destinationData.OctopusApiKey -Method POST
}