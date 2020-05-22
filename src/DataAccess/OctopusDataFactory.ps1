function Get-OctopusData
{
    param(
        $octopusUrl,
        $octopusApiKey,
        $spaceName
    )

    $octopusData = @{
        OctopusUrl = $octopusUrl;
        OctopusApiKey = $octopusApiKey
    }

    $octopusData.ApiInformation = Get-OctopusApi -OctopusUrl $octopusUrl -SpaceId $null -EndPoint "/api" -ApiKey $octopusApiKey
    $octopusData.Version = $octopusData.ApiInformation.Version
    Write-OctopusSuccess "The version of $octopusUrl is $($octopusData.Version)"

    $splitVersion = $octopusData.ApiInformation.Version -split "\."
    $octopusData.MajorVersion = [int]$splitVersion[0]
    $octopusData.MinorVersion = [int]$splitVersion[1]
    $octopusData.HasSpaces = $octopusData.MajorVersion -ge 2019
    Write-OctopusSuccess "This version of Octopus has spaces $($octopusData.HasSpaces)"

    $octopusData.HasRunbooks = ($octopusData.MajorVersion -ge 2019 -and $octopusData.MinorVersion -ge 11) -or $octopusData.MajorVersion -ge 2020
    Write-OctopusSuccess "This version of Octopus has runbooks $($octopusData.HasSpaces)"

    $octopusData.HasWorkers = ($octopusData.MajorVersion -ge 2018 -and $octopusData.MinorVersion -ge 7) -or $octopusData.MajorVersion -ge 2019
    Write-OctopusSuccess "This version of Octopus has workers $($octopusData.HasWorkers)"
        
    $octopusData.SpaceId = Get-OctopusSpaceId -octopusUrl $octopusUrl -octopusApiKey $octopusApiKey -hasSpaces $OctopusData.HasSpaces    

    Write-OctopusSuccess "Getting Environments for $spaceName in $octopusUrl"
    $octopusData.EnvironmentList = Get-OctopusEnvironmentList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId    
    
    Write-OctopusSuccess "Getting Worker Pools for $spaceName in $octopusUrl"
    $octopusData.WorkerPoolList = Get-OctopusWorkerPoolList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId -HasWorkers $octopusData.HasWorkers

    Write-OctopusSuccess "Getting Tenant Tags for $spaceName in $octopusUrl"
    $octopusData.TenantTagList = Get-OctopusTenantTagSet -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-OctopusSuccess "Getting Step Templates for $spaceName in $octopusUrl"
    $octopusData.StepTemplates = Get-OctopusStepTemplateList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId
    $octopusData.CommunityActionTemplates = Get-OctopusCommunityActionTemplates -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl 

    Write-OctopusSuccess "Getting Infrastructure Accounts for $spaceName in $octopusUrl"
    $octopusData.InfrastructureAccounts = Get-OctopusInfrastructureAccounts -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-OctopusSuccess "Getting Library Variable Sets for $spaceName in $octopusUrl"
    $octopusData.VariableSetList = Get-OctopusLibrarySetList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-OctopusSuccess "Getting Tenants for $spaceName in $octopusUrl"
    $octopusData.TenantList = Get-OctopusTenants -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-OctopusSuccess "Getting Lifecycles for $spaceName in $octopusUrl"
    $octopusData.LifeCycleList = Get-OctopusLifeCycles -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-OctopusSuccess "Getting Project Groups for $spaceName in $octopusUrl"
    $octopusData.ProjectGroupList = Get-ProjectGroups -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId
    
    Write-OctopusSuccess "Getting Projects for $spaceName in $octopusUrl"
    $octopusData.ProjectList = Get-OctopusProjectList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-OctopusSuccess "Getting Feed List for $spaceName in $octopusUrl"
    $octopusData.FeedList = Get-OctopusFeedList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-OctopusSuccess "Getting Script Modules for $spaceName in $OctopusUrl"
    $octopusData.ScriptModuleList = Get-OctopusScriptModules -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-OctopusSuccess "Getting Machine Policies for $spaceName in $OctopusUrl"
    $octopusData.MachinePolicyList = Get-OctopusMachinePolicies -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-OctopusSuccess "Getting Workers for $spaceName in $OctopusUrl"
    $octopusData.WorkerList = Get-OctopusWorkers -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-OctopusSuccess "Getting Targets for $spaceName in $OctopusUrl"
    $octopusData.TargetList = Get-OctopusTargets -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    return $octopusData
}