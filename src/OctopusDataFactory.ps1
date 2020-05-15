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

Function Get-OctopusProjectRunBooks
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

Function Get-OctopusInfrastructureAccounts
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "accounts?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

function Get-OctopusCommunityActionTemplates
{
    param(
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "communityactiontemplates?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $null
}

Function Get-OctopusTenantTagSet
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "tagsets?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusLifeCycles
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "lifecycles?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-ProjectGroups
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "projectgroups?skip=0&take=1000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
}

Function Get-OctopusTenants
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "tenants?skip=0&take=10000" -ApiKey $ApiKey -OctopusUrl $OctopusServerUrl -SpaceId $SpaceId
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
        Write-GreenOutput "Getting Space Information from $octopusUrl"
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
    Write-GreenOutput "The version of $octopusUrl is $($octopusData.ApiInformation.Version)"

    $splitVersion = $octopusData.ApiInformation.Version -split "\."
    $octopusData.HasSpaces = [int]$splitVersion[0] -ge 2019
    Write-GreenOutput "This version of Octopus has spaces $($octopusData.HasSpaces)"
    
    $octopusData.HasWorkers = ([int]$splitVersion[0] -ge 2018 -and [int]$splitVersion[1] -ge 7) -or [int]$splitVersion[0] -ge 2019
    Write-GreenOutput "This version of Octopus has workers $($octopusData.HasWorkers)"

    $octopusData.HasRunbooks = ([int]$splitVersion[0] -ge 2019 -and [int]$splitVersion[1] -ge 10) -or [int]$splitVersion[0] -ge 2020
    Write-GreenOutput "This version of Octopus has runbooks $($octopusData.HasRunBooks)"

    $octopusData.SpaceId = Get-OctopusSpaceId -octopusUrl $octopusUrl -octopusApiKey $octopusApiKey -hasSpaces $OctopusData.HasSpaces    

    Write-GreenOutput "Getting Environments for $spaceName in $octopusUrl"
    $octopusData.EnvironmentList = Get-OctopusEnvironmentList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId    
    
    Write-GreenOutput "Getting Worker Pools for $spaceName in $octopusUrl"
    $octopusData.WorkerPoolList = Get-OctopusWorkerPoolList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId -HasWorkers $octopusData.HasWorkers

    Write-GreenOutput "Getting Tenant Tags for $spaceName in $octopusUrl"
    $octopusData.TenantTagList = Get-OctopusTenantTagSet -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-GreenOutput "Getting Step Templates for $spaceName in $octopusUrl"
    $octopusData.StepTemplates = Get-OctopusStepTemplateList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId
    $octopusData.CommunityActionTemplates = Get-OctopusCommunityActionTemplates -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl 

    Write-GreenOutput "Getting Infrastructure Accounts for $spaceName in $octopusUrl"
    $octopusData.InfrastructureAccounts = Get-OctopusInfrastructureAccounts -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-GreenOutput "Getting Library Variable Sets for $spaceName in $octopusUrl"
    $octopusData.VariableSetList = Get-OctopusLibrarySetList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-GreenOutput "Getting Tenants for $spaceName in $octopusUrl"
    $octopusData.TenantList = Get-OctopusTenants -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-GreenOutput "Getting Lifecycles for $spaceName in $octopusUrl"
    $octopusData.LifeCycleList = Get-OctopusLifeCycles -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-GreenOutput "Getting Project Groups for $spaceName in $octopusUrl"
    $octopusData.ProjectGroupList = Get-ProjectGroups -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId
    
    Write-GreenOutput "Getting Projects for $spaceName in $octopusUrl"
    $octopusData.ProjectList = Get-OctopusProjectList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-GreenOutput "Getting Feed List for $spaceName in $octopusUrl"
    $octopusData.FeedList = Get-OctopusFeedList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    return $octopusData
}