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

Clear-Host
$ErrorActionPreference = "Stop"

$currentDate = Get-Date
$currentDateFormatted = $currentDate.ToString("yyyy_MM_dd_HH_mm")
$logPath = "$PSScriptRoot\Log_$currentDateFormatted.txt"
$cleanupLogPath = "$PSScriptRoot\CleanUp_$currentDateFormatted.txt"

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

function Write-VerboseOutput
{
    param($message)
    
    Add-Content -Value $message -Path $logPath    
}

function Write-GreenOutput
{
    param($message)

    Write-Host $message -ForegroundColor Green
    Write-VerboseOutput $message    
}

function Write-YellowOutput
{
    param($message)

    Write-Host $message -ForegroundColor Yellow    
    Write-VerboseOutput $message
}

function Write-CleanUpOutput
{
    param($message)

    Add-Content -Value $message -Path $cleanupLogPath
}

function Get-UserCloneDecision
{
    param($message)

    Write-YellowOutput $message

    $proceed = $false
    if ((Read-Host).ToLower() -eq "y")
    {
        Write-GreenOutput "You have entered Y, I will proceed"
        $proceed = $true
    }
    else
    {
        Write-YellowOutput "You have selected no, I will skip"
    }

    return $proceed
}

Function Get-OctopusApiItemList
{
    param (
        $EndPoint,
        $ApiKey
    )

    Write-VerboseOutput "Invoking $EndPoint"

    $results = Invoke-RestMethod -Method Get -Uri $EndPoint -Headers @{"X-Octopus-ApiKey"="$ApiKey"}   
    
    Write-VerboseOutput "$endPoint returned a list with $($results.Items.Length) item(s)" 

    return $results.Items
}

Function Get-OctopusApi
{
    param (
        $EndPoint,
        $ApiKey
    )

    Write-VerboseOutput "Invoking GET $EndPoint"

    $results = Invoke-RestMethod -Method Get -Uri $EndPoint -Headers @{"X-Octopus-ApiKey"="$ApiKey"}    

    return $results
}

Function Save-OctopusApi
{
    param (
        $EndPoint,
        $ApiKey,
        $Method,
        $Item
    )

    Write-VerboseOutput "Invoking $Method $EndPoint"

    if ($null -eq $item)
    {
        $results = Invoke-RestMethod -Method $Method -Uri $EndPoint -Headers @{"X-Octopus-ApiKey"="$ApiKey"}
    }
    else
    {
        $bodyAsJson = ConvertTo-Json $Item -Depth 10
        Write-VerboseOutput "Going to invoke $Method $EndPoint with the following body"
        Write-VerboseOutput $bodyAsJson

        $results = Invoke-RestMethod -Method $Method -Uri $EndPoint -Headers @{"X-Octopus-ApiKey"="$ApiKey"} -Body $bodyAsJson
    }

    return $results
}

function Save-OctopusApiItem
{
    param(
        $Item,
        $Endpoint,
        $ApiKey
    )

    $method = "POST"

    if ($null -ne $Item.Id)    
    {
        Write-VerboseOutput "Item has id, updating method call to PUT"
        $method = "Put"
        $endPoint = "$endPoint/$($Item.Id)"
    }

    $results = Save-OctopusApi -EndPoint $Endpoint $method $method -Item $Item -ApiKey $ApiKey

    Write-VerboseOutput $results

    return $results
}

function Get-OctopusItemByName
{
    param (
        $ItemList,
        $ItemName
        )    

    return ($ItemList | Where-Object {$_.Name -eq $ItemName})
}

function Get-OctopusItemById
{
    param (
        $ItemList,
        $ItemId
        ) 
        
    Write-VerboseOutput "Attempting to find $ItemId in the item list of $($ItemList.Length) item(s)"

    foreach($item in $ItemList)
    {
        Write-VerboseOutput "Checking to see if $($item.Id) matches with $ItemId"
        if ($item.Id -eq $ItemId)
        {
            Write-VerboseOutput "The Ids match, return the item $($item.Name)"
            return $item
        }
    }

    Write-VerboseOutput "No match found returning null"
    return $null    
}

function Convert-SourceIdToDestinationId
{
    param(
        $SourceList,
        $DestinationList,
        $IdValue
    )

    Write-VerboseOutput "Getting Name of $IdValue"
    $sourceItem = Get-OctopusItemById -ItemList $SourceList -ItemId $IdValue
    Write-VerboseOutput "The name of $IdValue is $($sourceItem.Name)"

    Write-VerboseOutput "Attempting to find $($sourceItem.Name) in Destination List"
    $destinationItem = Get-OctopusItemByName -ItemName $sourceItem.Name -ItemList $DestinationList
    Write-VerboseOutput "The destination id for $($sourceItem.Name) is $($destinationItem.Id)"

    if ($null -eq $destinationItem)
    {
        return $null
    }
    else
    {
        return $destinationItem.Id
    }
}

function Convert-SourceIdListToDestinationIdList
{
    param(
        $SourceList,
        $DestinationList,
        $IdList
    )

    $NewIdList = @()
    Write-VerboseOutput "Converting id list with $($IdList.Length) item(s) over to destination space"     
    foreach ($idValue in $idList)
    {
        $ConvertedId = Convert-SourceIdToDestinationId -SourceList $SourceList -DestinationList $DestinationList -IdValue $IdValue

        if ($null -ne $ConvertedId)
        {
            $NewIdList += $ConvertedId
        }
    }

    return $NewIdList
}

function Get-OctopusSpaceList
{
    param (
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/spaces?skip=0&take=1000" -ApiKey $ApiKey 
}

Function Get-OctopusProjectList
{
    param (        
        $SpaceId,        
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/Projects?skip=0&take=1000" -ApiKey $ApiKey 
}

Function Get-OctopusEnvironmentList
{
    param (        
        $SpaceId,        
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/Environments?skip=0&take=1000" -ApiKey $ApiKey 
}

Function Get-OctopusLibrarySetList
{
    param (
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )
    
    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/libraryvariablesets?skip=0&take=1000&contentType=Variables" -ApiKey $ApiKey
}

Function Get-OctopusLibrarySetVariables
{
    param(
        $VariableSetId,
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )
    
    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$($SpaceId)/variables/$VariableSetId" -ApiKey $ApiKey
}

Function Get-OctopusStepTemplateList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/actiontemplates?skip=0&take=1000" -ApiKey $ApiKey
}

Function Get-OctopusProjectRunBooks
{
    param(
        $ProjectId,
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/projects/$ProjectId/runbooks?skip=0&take=1000" -ApiKey $ApiKey
}

Function Get-OctopusRunbookProcess
{
    param(
        $RunbookProcessId,
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/runbookProcesses/$RunbookProcessId" -ApiKey $ApiKey
}

Function Get-OctopusWorkerPoolList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/workerpools?skip=0&take=1000" -ApiKey $ApiKey
}

Function Get-OctopusFeedList
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/feeds?skip=0&take=1000" -ApiKey $ApiKey
}

Function Get-OctopusInfrastructureAccounts
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/accounts?skip=0&take=1000" -ApiKey $ApiKey
}

function Get-OctopusCommunityActionTemplates
{
    param(
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/communityactiontemplates?skip=0&take=1000" -ApiKey $ApiKey
}

Function Get-OctopusTenantTagSet
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/tagsets?skip=0&take=1000" -ApiKey $ApiKey
}

Function Get-OctopusLifeCycles
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/lifecycles?skip=0&take=1000" -ApiKey $ApiKey
}

Function Get-ProjectGroups
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/projectgroups?skip=0&take=1000" -ApiKey $ApiKey
}

function Copy-OctopusObject
{
    param(
        $ItemToCopy
    )

    $copyOfItem = $ItemToCopy | ConvertTo-Json -Depth 10
    $copyOfItem = $copyOfItem | ConvertFrom-Json

    return $copyOfItem
}

Function Get-OctopusTenants
{
    param(
        $SpaceId,
        $OctopusServerUrl,
        $ApiKey
    )

    return Get-OctopusApiItemList -EndPoint "$OctopusServerUrl/api/$SpaceId/tenants?skip=0&take=10000" -ApiKey $ApiKey
}

function Get-OctopusFilteredList
{
    param(
        $itemList,
        $itemType,
        $filters
    )

    $filteredList = @()  
    
    Write-GreenOutput "Creating filter list for $itemType"

    if ([string]::IsNullOrWhiteSpace($filters) -eq $false)
    {
        $splitFilters = $filters -split ","

        foreach($item in $itemList)
        {
            foreach ($filter in $splitFilters)
            {
                Write-VerboseOutput "Checking to see if $filter matches $($item.Name)"
                if ([string]::IsNullOrWhiteSpace($filter))
                {
                    continue
                }
                if (($filter).ToLower() -eq "all")
                {
                    Write-VerboseOutput "The filter is 'all' -> adding $($item.Name) to $itemType filtered list"
                    $filteredList += $item
                }
                elseif ($item.Name -match $filter)
                {
                    Write-VerboseOutput "The filter $filter matches $($item.Name), adding $($item.Name) to $itemType filtered list"
                    $filteredList += $item
                }
                else
                {
                    Write-VerboseOutput "The item $($item.Name) does not match filter $filter"
                }
            }
        }

        if ($filteredList.Length -eq 0)
        {
            Write-YellowOutput "No $itemType items were found to clone, skipping"
        }
        else
        {
            Write-GreenOutput "$itemType items were found to clone, starting clone for $itemType"
        }
    }
    else
    {
        Write-YellowOutput "The filter for $itemType was not set.  No $itemType will be cloned.  If you wish to clone all $itemType use 'all' or use a comma seperated list (wild cards supported), IE 'AWS*,Space Infrastructure."
    }

    return $filteredList
}

function Copy-OctopusSimpleItems
{
    param(
        $SourceItemList,
        $DestinationItemList,
        $DestinationSpaceId,                
        $ApiKey,
        $EndPoint,
        $ItemTypeName,
        $DestinationCanBeOverwritten
    )

    foreach ($clonedItem in $SourceItemList)
    {
        Copy-OctopusItem -ClonedItem $clonedItem -DestinationSpaceId $DestinationSpaceId -ApiKey $ApiKey -EndPoint $EndPoint -DestinationItemList $DestinationItemList -ItemTypeName $ItemTypeName -DestinationCanBeOverwritten $DestinationCanBeOverwritten
    }
}

function Copy-OctopusItem
{
    param
    (
        $ClonedItem,
        $DestinationItemList,
        $DestinationSpaceId,
        $ApiKey,
        $EndPoint,
        $ItemTypeName,
        $DestinationCanBeOverwritten
    )

    Write-VerboseOutput "Cloning $ItemTypeName $($clonedItem.Name)"
        
    $matchingItem = Get-OctopusItemByName -ItemName $clonedItem.Name -ItemList $DestinationItemList

    Write-VerboseOutput -message $ClonedItem
    $copyOfItemToClone = Copy-OctopusObject -ItemToCopy $ClonedItem
    $copyOfItemToClone.SpaceId = $DestinationSpaceId

    If ($null -eq $matchingItem)
    {
        Write-GreenOutput "$ItemTypeName $($clonedItem.Name) was not found in destination, creating new record."        
        $copyOfItemToClone.Id = $null                        
        Save-OctopusApiItem -Item $copyOfItemToClone -Endpoint $EndPoint -ApiKey $ApiKey
    }
    elseif ($DestinationCanBeOverwritten -eq $false)
    {
        Write-GreenOutput "The $ItemTypeName $($ClonedItem.Name) already exists. Skipping."
    }
    elseif ((Get-UserCloneDecision -message "Matching $ItemTypeName found $($matchingItem.Name).  Do you wish to overwrite it? Y/N"))
    {        
        Write-VerboseOutput "Overwriting $ItemTypeName $($clonedItem.Name) with data from source."
        $copyOfItemToClone.Id = $matchingItem.Id
        Save-OctopusApiItem -Item $copyOfItemToClone -Endpoint $EndPoint -ApiKey $ApiKey
    }
    else
    {
        Write-GreenOutput "Cloning of $ItemTypeName $($clonedItem.Name) has been skipped."
    }                
}

function Copy-OctopusEnvironments
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.EnvironmentList -itemType "Environment" -filters $cloneScriptOptions.EnvironmentsToClone        
    
    Copy-OctopusSimpleItems -SourceItemList $filteredList -DestinationItemList $destinationData.EnvironmentList -DestinationSpaceId $destinationData.SpaceId -ApiKey $destinationData.OctopusApiKey -EndPoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/Environments" -ItemTypeName "Environment" -DestinationCanBeOverwritten $false

    Write-GreenOutput "Reloading destination environment list"    
    $destinationData.EnvironmentList = Get-OctopusEnvironmentList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}

function Copy-OctopusWorkerPools
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.WorkerPoolList -itemType "Worker Pool List" -filters $cloneScriptOptions.WorkerPoolsToClone
    
    Copy-OctopusSimpleItems -SourceItemList $filteredList -DestinationItemList $destinationData.WorkerPoolList -DestinationSpaceId $destinationData.SpaceId -ApiKey $destinationData.OctopusApiKey -EndPoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/WorkerPools" -ItemTypeName "Worker Pools" -DestinationCanBeOverwritten $false

    Write-GreenOutput "Reloading destination worker pool list"
    $destinationData.WorkerPoolList = Get-OctopusWorkerPoolList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}

function Copy-OctopusProjectGroups
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.ProjectGroupList -itemType "Project Groups" -filters $cloneScriptOptions.ProjectGroupsToClone
    
    Copy-OctopusSimpleItems -SourceItemList $filteredList -DestinationItemList $destinationData.ProjectGroupList -EndPoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/projectgroups" -ApiKey $($destinationData.OctopusApiKey) -destinationSpaceId $($destinationData.SpaceId) -ItemTypeName "Project Groups" -DestinationCanBeOverwritten $false

    Write-GreenOutput "Reloading destination project groups"
        
    $destinationData.ProjectGroupList = Get-ProjectGroups -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}

function Copy-OctopusTenantTags
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.TenantTagList -itemType "Tenant Tags" -filters $cloneScriptOptions.TenantTagsToClone
    
    Copy-OctopusSimpleItems -SourceItemList $filteredList -DestinationItemList $destinationData.TenantTagList -EndPoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/TagSets" -ApiKey $($destinationData.OctopusApiKey) -destinationSpaceId $($destinationData.SpaceId) -ItemTypeName "Tenant Tag Set" -DestinationCanBeOverwritten $true

    Write-GreenOutput "Reloading destination Tenant Tag Set"
    
    $destinationData.TenantTagList = Get-OctopusTenantTagSet -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}

function Copy-OctopusExternalFeeds
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.FeedList -itemType "Feeds" -filters $cloneScriptOptions.ExternalFeedsToClone
    
    Copy-OctopusSimpleItems -SourceItemList $filteredList -DestinationItemList $destinationData.FeedList -EndPoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/Feeds" -ApiKey $($destinationData.OctopusApiKey) -destinationSpaceId $($destinationData.SpaceId) -ItemTypeName "Feed" -DestinationCanBeOverwritten $false

    Write-GreenOutput "Reloading destination feed list"
    
    $destinationData.FeedList = Get-OctopusFeedList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}

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

            Save-OctopusApi -EndPoint "$($destinationData.OctopusUrl)/api/communityactiontemplates/$($destinationTemplate.Id)/installation/$($destinationData.SpaceId)" -ApiKey $destinationData.OctopusApiKey -Method POST
        }        
        elseif ($null -eq $clonedItem.CommunityActionTemplateId)
        {
            Write-GreenOutput "This is a custom step template following normal cloning logic"
            Copy-OctopusItem -ClonedItem $clonedItem -DestinationItemList $destinationData.StepTemplates -DestinationSpaceId $destinationData.SpaceId -ApiKey $destinationData.OctopusApiKey -EndPoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/actiontemplates" -ItemTypeName "Custom Step Template" -DestinationCanBeOverwritten $cloneScriptOptions.OverwriteExistingCustomStepTemplates
        }                
    }

    Write-GreenOutput "Reloading step template list"
    
    $destinationData.StepTemplates = Get-OctopusStepTemplateList -SpaceId $($destinationData.SpaceId) -OctopusServerUrl $($destinationData.OctopusUrl) -ApiKey $($destinationData.OctopusApiKey)
}

function Copy-OctopusInfrastructureAccounts
{
    param(
        $SourceData,
        $DestinationData,
        $CloneScriptOptions
    )

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.InfrastructureAccounts -itemType "Infrastructure Accounts" -filters $cloneScriptOptions.InfrastructureAccountsToClone

    Write-CleanUpOutput "Starting Infrastructure Accounts"
    foreach($account in $filteredList)
    {
        Write-VerboseOutput "Cloning the account $($account.Name)"

        $matchingAccount = Get-OctopusItemByName -ItemName $account.Name -ItemList $DestinationData.InfrastructureAccounts

        if ($null -eq $matchingAccount)
        {
            Write-GreenOutput "The account $($account.Name) does not exist.  Creating it."

            $accountClone = Copy-OctopusObject -ItemToCopy $account
            $accountClone.Id = $null
            $accountClone.SpaceId = $($destinationData.SpaceId)

            if ($accountClone.AccountType -eq "AmazonWebServicesAccount")
            {
                $accountClone.AccessKey = "AKIABCDEFGHI3456789A"
                $accountClone.SecretKey.HasValue = $false
                $accountClone.SecretKey.NewValue = "DUMMY VALUE DUMMY VALUE"
            }
            elseif ($accountClone.AccountType -eq "AzureServicePrincipal")
            {
                $accountClone.SubscriptionNumber = New-Guid
                $accountClone.ClientId = New-Guid
                $accountClone.TenantId = New-Guid
                $accountClone.Password.HasValue = $false
                $accountClone.Password.NewValue = "DUMMY VALUE DUMMY VALUE"
            }

            $NewEnvironmentIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $accountClone.EnvironmentIds            
            $accountClone.EnvironmentIds = @($NewEnvironmentIds)

            $NewTenantIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.TenantList -DestinationList $DestinationData.TenantList -IdList $accountClone.TenantIds
            $accountClone.TenantIds = @($NewTenantIds)

            if ($accountClone.TenantIds.Length -eq 0)
            {
                $accountClone.TenantedDeploymentParticipation = "Untenanted"
            }            

            Save-OctopusApiItem -Item $accountClone -Endpoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/accounts" -ApiKey $DestinationData.OctopusApiKey
            Write-YellowOutput "Account successfully cloned.  WARNING WARNING WARNING account values have dummy values."
            Write-CleanUpOutput "Account $($account.Name) was created with dummy values."
        }
        else
        {
            Write-GreenOutput "The account $($account.Name) already exists.  Skipping it."
        }
    }

    Write-GreenOutput "Reloading the destination accounts"
    
    $destinationData.InfrastructureAccounts = Get-OctopusInfrastructureAccounts -OctopusServerUrl $($destinationData.OctopusUrl) -ApiKey $($destinationData.OctopusApiKey) -SpaceId $($destinationData.SpaceId)
}

function Copy-OctopusVariableSetValues
{
    param
    (
        $SourceVariableSetVariables,
        $DestinationVariableSetVariables,        
        $SourceData,
        $DestinationData,
        $SourceProjectData,
        $DestinationProjectData,
        $CloneScriptOptions
    )
    
    $variableTracker = @{}        

    foreach ($octopusVariable in $sourceVariableSetVariables.Variables)
    {                     
        $variableName = $octopusVariable.Name        
        
        if (Get-Member -InputObject $octopusVariable.Scope -Name "Environment" -MemberType Properties)
        {
            Write-VerboseOutput "$variableName has environment scoping, converting to destination values"
            $NewEnvironmentIds = Convert-SourceIdListToDestinationIdList -SourceList $sourcedata.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $octopusVariable.Scope.Environment
            $octopusVariable.Scope.Environment = @($NewEnvironmentIds)            
        }

        if (Get-Member -InputObject $octopusVariable.Scope -Name "Channel" -MemberType Properties)
        {
            Write-VerboseOutput "$variableName has channel scoping, converting to destination values"
            $NewChannelIds = Convert-SourceIdListToDestinationIdList -SourceList $sourceProjectData.ChannelList -DestinationList $DestinationProjectData.ChannelList -IdList $octopusVariable.Scope.Channel
            $octopusVariable.Scope.Channel = @($NewChannelIds)            
        }

        if (Get-Member -InputObject $octopusVariable.Scope -Name "ProcessOwner" -MemberType Properties)
        {
            Write-VerboseOutput "$variableName has process owner scoping, converting to destination values"
            $NewOwnerIds = @()
            foreach($value in $octopusVariable.Scope.ProcessOwner)
            {
                if ($value -contains "Projects-")
                {
                    $NewOwnerIds += $DestinationProjectData.Project.Id
                }
                elseif($value -contains "Runbooks-")
                {
                    $NewOwnerIds += Convert-SourceIdToDestinationId -SourceList $SourceProjectData.RunbookList -DestinationList $DestinationProjectData.RunbookList -IdValue $value
                }
            }
            
            $octopusVariable.Scope.ProcessOwner = @($NewOwnerIds)            
        }

        if ($octopusVariable.Type -match ".*Account")
        {
            Write-VerboseOutput "$variableName is an account value, converting to destination account"
            $octopusVariable.Value = Convert-SourceIdToDestinationId -SourceList $sourceData.InfrastructureAccounts -DestinationList $destinationData.InfrastructureAccounts -IdValue $octopusVariable.Value
        }

        if ($octopusVariable.IsSensitive -eq $true)
        {
            $octopusVariable.Value = "Dummy Value"
        }

        $trackingName = $variableName -replace "\.", ""        
        
        Write-VerboseOutput "Cloning $variableName"
        if ($null -eq $variableTracker[$trackingName])
        {
            Write-VerboseOutput "This is the first time we've seen $variableName"
            $variableTracker[$trackingName] = 1
        }
        else
        {
            $variableTracker.$trackingName += 1
            Write-VerboseOutput "We've now seen $variableName $($variableTracker[$trackingName]) times"
        }

        $foundCounter = 0
        $foundIndex = -1
        $variableExistsOnDestination = $false        
        for($i = 0; $i -lt $DestinationVariableSetVariables.Variables.Length; $i++)
        {            
            if ($DestinationVariableSetVariables.Variables[$i].Name -eq $variableName)
            {
                $variableExistsOnDestination = $true
                $foundCounter += 1
                if ($foundCounter -eq $variableTracker[$trackingName])
                {
                    $foundIndex = $i
                }
            }
        }        
        
        if ($foundCounter -gt 1 -and $variableExistsOnDestination -eq $true -and $CloneScriptOptions.AddAdditionalVariableValuesOnExistingVariableSets -eq $true)
        {
            Write-YellowOutput "The variable $variableName already exists on destination. You selected to skip duplicate instances, skipping"
        }
        elseif ($foundIndex -eq -1)
        {
            Write-GreenOutput "New variable $variableName value found.  This variable has appeared so far $($variableTracker[$trackingName]) time(s) in the source variable set.  Adding to list."
            $DestinationVariableSetVariables.Variables += $octopusVariable
        }
        elseif ($CloneScriptOptions.OverwriteExistingVariables -eq $false)
        {
            Write-VerboseOutput "The variable $variableName already exists on the host and you elected to only copy over new items, skipping this one."
        }                                         
        elseif ($foundIndex -gt -1 -and $DestinationVariableSetVariables.Variables[$foundIndex].IsSensitive -eq $true)
        {
            Write-GreenOutput "The variable $variableName at value index $($variableTracker[$trackingName]) is sensitive, leaving as is on the destination."
        }
        elseif ($foundIndex -gt -1 -and (Get-UserCloneDecision -message "The variable $variableName at value index $($variableTracker[$trackingName]) already exists. Would you like to overwrite the value? Y/N"))
        {
            $DestinationVariableSetVariables.Variables[$i].Value = $octopusVariable.Value
            if ($octopusVariable.Value -eq "Dummy Value")         
            {
                Write-YellowOutput "The variable $variableName is a new sensitive variable found, the value was set to 'Dummy Value'.  This information is logged in the clean-up log."
                Write-CleanUpOutput "The variable $variableName is a sensitive variable, value set to 'Dummy Value'"
            }
        }        
    }

    Save-OctopusApi -EndPoint "$($destinationData.OctopusUrl)/$($DestinationVariableSetVariables.Links.Self)" -ApiKey $DestinationData.OctopusApiKey -Method "PUT" -Item $DestinationVariableSetVariables
    Write-GreenOutput "Variables successfully cloned."
}

function Copy-OctopusLibraryVariableSets
{
    param
    (
        $SourceData,
        $DestinationData,
        $cloneScriptOptions
    )

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.VariableSetList -itemType "Library Variable Sets" -filters $cloneScriptOptions.LibraryVariableSetsToClone

    foreach($sourceVariableSet in $filteredList)
    {
        Write-VerboseOutput "Starting clone of $($sourceVariableSet.Name)"

        $destinationVariableSet = Get-OctopusItemByName -ItemList $destinationData.VariableSetList -ItemName $sourceVariableSet.Name

        if ($null -eq $destinationVariableSet)
        {
            Write-GreenOutput "Variable Set $($sourceVariableSet.Name) was not found in destination, creating new base record."
            $copySourceVariableSet = Copy-OctopusObject -ItemToCopy $sourceVariableSet             

            $copySourceVariableSet.SpaceId = $($destinationData.SpaceId)
            $copySourceVariableSet.VariableSetId = $null
            $copySourceVariableSet.Id = $null

            $destinationVariableSet = Save-OctopusApi -EndPoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/libraryvariablesets" -ApiKey $($destinationData.OctopusApiKey) -Method POST -Item $copySourceVariableSet
        }
        else
        {
            Write-GreenOutput "Variable Set $($sourceVariableSet.Name) already exists in destination."
        }

        Write-VerboseOutput "The variable set has been created, time to copy over the variables themselves"

        $sourceVariableSetVariables = Get-OctopusApi -EndPoint "$($sourceData.OctopusUrl)/$($sourceVariableSet.Links.Variables)" -ApiKey $sourceData.OctopusApiKey 
        $destinationVariableSetVariables = Get-OctopusApi -EndPoint "$($destinationData.OctopusUrl)/$($destinationVariableSet.Links.Variables)" -ApiKey $destinationData.OctopusApiKey

        Write-CleanUpOutput "Starting clone of $($sourceVariableSet.Name)"
        Copy-OctopusVariableSetValues -SourceVariableSetVariables $sourceVariableSetVariables -DestinationVariableSetVariables $destinationVariableSetVariables -SourceData $SourceData -DestinationData $DestinationData -SourceProjectData @{} -DestinationProjectData @{} -CloneScriptOptions $cloneScriptOptions
    }

    Write-GreenOutput "Reloading destination variable set list"
    
    $destinationData.VariableSetList = Get-OctopusLibrarySetList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}

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
        $lifeCycleToClone = Copy-OctopusObject -ItemToCopy $lifecycle
        $lifeCycleToClone.SpaceId = $DestinationSpaceId

        foreach ($phase in $lifeCycleToClone.Phases)
        {
            $NewEnvironmentIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $phase.OptionalDeploymentTargets            
            $phase.OptionalDeploymentTargets = @($NewEnvironmentIds)

            $NewEnvironmentIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $phase.AutomaticDeploymentTargets            
            $phase.AutomaticDeploymentTargets = @($NewEnvironmentIds)
        }

        Copy-OctopusItem -ClonedItem $lifeCycleToClone -DestinationItemList $DestinationData.LifeCycleList -DestinationSpaceId $DestinationData.SpaceId -ApiKey $DestinationData.OctopusApiKey -EndPoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/lifecycles" -ItemTypeName "Lifecycle" -DestinationCanBeOverwritten $CloneScriptOptions.OverwriteExistingLifecyclesPhases
    }

    Write-GreenOutput "Reloading destination lifecycles"
    
    $destinationData.LifeCycleList = Get-OctopusLifeCycles -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId 
}

function Copy-OctopusProjectChannels
{
    param(
        $sourceChannelList,
        $destinationChannelList,
        $destinationProject,
        $sourceData,
        $destinationData
    )

    foreach($channel in $sourceChannelList)
    {
        $matchingChannel = Get-OctopusItemByName -ItemList $destinationChannelList -ItemName $channel.Name

        if ($null -eq $matchingChannel)
        {
            $cloneChannel = Copy-OctopusObject -ItemToCopy $channel
            $cloneChannel.Id = $null
            $cloneChannel.ProjectId = $destinationProject.Id
            if ($null -ne $cloneChannel.LifeCycleId)
            {
                $cloneChannel.LifeCycleId = Convert-SourceIdToDestinationId -SourceList $SourceData.LifeCycleList -DestinationList $DestinationData.LifeCycleList -IdValue $cloneChannel.LifeCycleId
            }

            $cloneChannel.Rules = @()

            Write-GreenOutput "The channel $($channel.Name) does not exist for the project $($destinationProject.Name), creating one now.  Please note, I cannot create version rules, so those will be emptied out"
            Save-OctopusApiItem -Item $cloneChannel -Endpoint "$($DestinationData.OctopusUrl)/api/$($destinationData.SpaceId)/channels" -ApiKey $DestinationData.OctopusApiKey
        }        
        else
        {
            Write-GreenOutput "The channel $($channel.Name) already exists for project $($destinationProject.Name).  Skipping it."
        }
    }
}

function Copy-ProcessStepAction
{
    param(
        $sourceAction,
        $sourceChannelList,
        $destinationChannelList,
        $sourceData,
        $destinationData
    )
        
    $action = Copy-OctopusObject -ItemToCopy $sourceAction
    $action.PSObject.Properties.Remove("Id")

    if ($null -ne $action.WorkerPoolId)
    {
        $action.WorkerPoolId = Convert-SourceIdToDestinationId -SourceList $SourceData.WorkerPoolList -DestinationList $DestinationData.WorkerPoolList -IdValue $action.WorkerPoolId                             
    }

    $NewEnvironmentIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $action.Environments            
    $action.Environments = @($NewEnvironmentIds)

    $NewEnvironmentIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $action.ExcludedEnvironments            
    $action.ExcludedEnvironments = @($NewEnvironmentIds)

    $NewChannelIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceChannelList -DestinationList $destinationChannelList -IdList $action.Channels
    $action.Channels = @($NewChannelIds)

    if ([bool]($action.PSobject.Properties.Value -Like "*Octopus.Action.Template.Id*"))
    {                                        
        $action.Properties.'Octopus.Action.Template.Id' = Convert-SourceIdToDestinationId -SourceList $sourceData.StepTemplates -DestinationList $destinationData.StepTemplates -IdValue $action.Properties.'Octopus.Action.Template.Id' 
        $stepTemplate = Get-OctopusItemById -ItemList $destinationData.StepTemplates -ItemId $action.Properties.'Octopus.Action.Template.Id'
        $action.Properties.'Octopus.Action.Template.Version' = $stepTemplate.Version

        foreach ($parameter in $stepTemplate.Parameters)
        {                                
            $controlType = $parameter.DisplaySettings.'Octopus.ControlType'
            Write-VerboseOutput "$($parameter.Name) is control type is $controlType"

            if ($controlType -eq "Package")
            {
                $action.Properties.$($parameter.Name) = ""
            }                
        }
    }

    if ([bool]($action.PSobject.Properties.Value -Like "*Octopus.Action.Manual.ResponsibleTeamIds*"))
    {                                        
        $action.Properties.'Octopus.Action.Manual.ResponsibleTeamIds' = "team-managers"
    }

    if ([bool]($action.PSobject.Properties.Value -like "*Octopus.Action.Package.FeedId*"))
    {
        $action.Properties.'Octopus.Action.Package.FeedId' = Convert-SourceIdToDestinationId -SourceList $sourceData.FeedList -DestinationList $destinationData.FeedList -IdValue $action.Properties.'Octopus.Action.Package.FeedId'
    }

    if ($action.Packages.Length -gt 0)
    {
        Write-YellowOutput "$($action.Name) has package references, I have to nuke them on the initial copy, please recreate them.  This information is logged in the clean-up log."
        Write-CleanUpOutput "Removed package references from $($action.Name)"
        $action.Packages = @()
    }
    
    return $action    
}

function Copy-OctopusDeploymentProcess
{
    param(
        $sourceChannelList,
        $destinationChannelList,
        $sourceData,
        $destinationData,
        $sourceDeploymentProcessSteps,
        $destinationDeploymentProcessSteps
    )

    Write-VerboseOutput "Looping through the source steps to get them added"
    $newDeploymentProcessSteps = @()
    foreach($step in $sourceDeploymentProcessSteps)
    {
        $matchingStep = Get-OctopusItemByName -ItemList $destinationDeploymentProcessSteps -ItemName $step.Name
        
        $newStep = $false
        if ($null -eq $matchingStep)
        {
            Write-VerboseOutput "The step $($step.Name) was not found, cloning from source and removing id"            
            $stepToAdd = Copy-OctopusObject -ItemToCopy $step
            $stepToAdd.PSObject.Properties.Remove("Id")                          
            $newStep = $true
        }
        else
        {
            Write-VerboseOutput "Matching step $($step.Name) found, using that existing step"
            $stepToAdd = Copy-OctopusObject -ItemToCopy $matchingStep                      
        }

        Write-VerboseOutput "Looping through the source actions to add them to the step"
        $newStepActions = @()
        foreach ($action in $step.Actions)
        {
            $matchingAction = Get-OctopusItemByName -ItemList $stepToAdd.Actions -ItemName $action.Name

            if ($null -eq $matchingAction)
            {
                Write-VerboseOutput "The action $($action.Name) doesn't exist for the step, adding that to the list"
                $newStepActions += Copy-ProcessStepAction -sourceAction $action -sourceChannelList $sourceChannelList -destinationChannelList $destinationChannelList -sourceData $sourceData -destinationData $destinationData         
            }
            elseif ($newStep -eq $true)
            {
                Write-VerboseOutput "The step $($step.Name) is new, cloning the action from the source"
                $newStepActions += Copy-ProcessStepAction -sourceAction $action -sourceChannelList $sourceChannelList -destinationChannelList $destinationChannelList -sourceData $sourceData -destinationData $destinationData         
            }
            else
            {
                Write-VerboseOutput "The action $($action.Name) already exists for the step, adding existing item to list"
                $newStepActions += Copy-OctopusObject -ItemToCopy $matchingAction
            }
        }

        Write-VerboseOutput "Looping through the destination step to make sure we didn't miss any actions"
        foreach ($action in $stepToAdd.Actions)
        {
            $matchingAction = Get-OctopusItemByName -ItemList $step.Actions -ItemName $action.Name

            if ($null -eq $matchingAction)
            {
                Write-VerboseOutput "The action $($action.Name) didn't exist at the source, adding that back to the destination list"
                $newStepActions += Copy-OctopusObject -ItemToCopy $action
            }
        }
        
        $stepToAdd.Actions = $newStepActions
        $newDeploymentProcessSteps += $stepToAdd
    }

    Write-VerboseOutput "Looping through the destination deployment process steps to make sure we didn't miss anything"
    foreach ($step in $destinationDeploymentProcessSteps)
    {
        $matchingStep = Get-OctopusItemByName -ItemList $sourceDeploymentProcessSteps -ItemName $step.Name

        if ($null -eq $matchingStep)
        {
            Write-VerboseOutput "The step $($step.Name) didn't exist in the source, adding that back to the destiantion list"
            $newDeploymentProcessSteps += Copy-OctopusObject -ItemToCopy $step
        }
    }

    return $newDeploymentProcessSteps
}

function Copy-OctopusProjectDeploymentProcess
{
    param(
        $sourceChannelList,
        $destinationChannelList,
        $destinationProject,        
        $sourceData,
        $destinationData
    )

    Write-GreenOutput "Syncing deployment process for $($destinationProject.Name)"
    $sourceDeploymentProcess = Get-OctopusApi -EndPoint "$($SourceData.OctopusUrl)/$($project.Links.DeploymentProcess)" -ApiKey $SourceData.OctopusApiKey
    $destinationDeploymentProcess = Get-OctopusApi -EndPoint "$($destinationData.OctopusUrl)/$($destinationProject.Links.DeploymentProcess)" -ApiKey $destinationData.OctopusApiKey
    
    $destinationDeploymentProcess.Steps = Copy-OctopusDeploymentProcess -sourceChannelList $sourceChannelList -destinationChannelList $destinationChannelList -sourceData $sourceData -destinationData $destinationData -sourceDeploymentProcessSteps $sourceDeploymentProcess.Steps -destinationDeploymentProcessSteps $destinationDeploymentProcess.Steps

    Save-OctopusApiItem -Item $destinationDeploymentProcess -Endpoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/deploymentprocesses" -ApiKey $destinationData.OctopusApiKey           
}

function Copy-OctopusProject
{
    param(
        $sourceData,
        $destinationData,
        $sourceProject
    )

    $matchingProject = Get-OctopusItemByName -ItemList $DestinationData.ProjectList -ItemName $sourceProject.Name               

    if ($null -eq $matchingProject)
    {            
        $copyOfProject = Copy-OctopusObject -ItemToCopy $sourceProject

        $copyOfProject.Id = $null
        $copyOfProject.DeploymentProcessId = $null
        $copyOfProject.VariableSetId = $null
        $copyOfProject.ClonedFromProjectId = $null
        $copyOfProject.SpaceId = $DestinationData.SpaceId
        $VariableSetIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.VariableSetList -DestinationList $DestinationData.VariableSetList -IdList $copyOfProject.IncludedLibraryVariableSetIds            
        $copyOfProject.IncludedLibraryVariableSetIds = @($VariableSetIds)
        $copyOfProject.VersioningStrategy.Template = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
        $copyOfProject.VersioningStrategy.DonorPackage = $null
        $copyOfProject.VersioningStrategy.DonorPackageStepId = $null
        $copyOfProject.ReleaseCreationStrategy.ChannelId = $null
        $copyOfProject.ReleaseCreationStrategy.ReleaseCreationPackage = $null
        $copyOfProject.ReleaseCreationStrategy.ReleaseCreationPackageStepId = $null
        $copyOfProject.ProjectGroupId = Convert-SourceIdToDestinationId -SourceList $SourceData.ProjectGroupList -DestinationList $DestinationData.ProjectGroupList -IdValue $copyOfProject.ProjectGroupId
        $copyOfProject.LifeCycleId = Convert-SourceIdToDestinationId -SourceList $SourceData.LifeCycleList -DestinationList $DestinationData.LifeCycleList -IdValue $copyOfProject.LifeCycleId        

        Save-OctopusApiItem -Item $copyOfProject -Endpoint "$($DestinationData.OctopusUrl)/api/$($DestinationData.SpaceId)/projects" -ApiKey $DestinationData.OctopusApiKey                    

        return $true
    }
    else
    {            
        $matchingProject.TenantedDeploymentMode = $sourceProject.TenantedDeploymentMode
        $matchingProject.DefaultGuidedFailureMode = $sourceProject.DefaultGuidedFailureMode
        $matchingProject.ReleaseNotesTemplate = $sourceProject.ReleaseNotesTemplate 
        $matchingProject.DeploymentChangesTemplate = $sourceProject.DeploymentChangesTemplate
        $matchingProject.Description = $sourceProject.Description                   

        Save-OctopusApiItem -Item $matchingProject -Endpoint "$($DestinationData.OctopusUrl)/api/$($DestinationData.SpaceId)/projects" -ApiKey $DestinationData.OctopusApiKey        

        return $false
    }    
}

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

    $sourceRunbooks = Get-OctopusApiItemList -EndPoint "$($SourceData.OctopusUrl)/api/$($sourceData.SpaceId)/projects/$($sourceProject.Id)/runbooks" -ApiKey $sourcedata.OctopusApiKey
    $destinationRunbooks = Get-OctopusApiItemList -EndPoint "$($DestinationData.OctopusUrl)/api/$($DestinationData.SpaceId)/projects/$($destinationProject.Id)/runbooks" -ApiKey $destinationData.OctopusApiKey

    foreach ($runbook in $sourceRunbooks)
    {
        $destinationRunbook = Get-OctopusItemByName -ItemList $destinationRunbooks -ItemName $runbook.Name

        $canProceed = $false
        if ($null -eq $destinationRunbook)
        {
            $runbookToClone = Copy-OctopusObject -ItemToCopy $runbook

            $runbookToClone.Id = $null
            $runbookToClone.ProjectId = $destinationProject.Id
            $runbookToClone.PublishedRunbookSnapshotId = $null
            $runbookToClone.RunbookProcessId = $null
            $runbookToClone.SpaceId = $destinationData.SpaceId

            Write-GreenOutput "The runbook $($runbook.Name) for $($destinationProject.Name) doesn't exist, creating it now"
            $destinationRunbook = Save-OctopusApiItem -Item $runbookToClone -Endpoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/runbooks" -ApiKey $destinationData.OctopusApiKey    
            $canProceed = $true
        }
        
        $sourceRunbookProcess = Get-OctopusApi -EndPoint "$($SourceData.OctopusUrl)/$($runbook.Links.RunbookProcesses)" -ApiKey $sourcedata.OctopusApiKey
        $destinationRunbookProcess = Get-OctopusApi -EndPoint "$($destinationData.OctopusUrl)/$($destinationRunbook.Links.RunbookProcesses)" -ApiKey $destinationData.OctopusApiKey

        Write-CleanUpOutput "Syncing deployment process for $($runbook.Name)"
        Write-GreenOutput "Syncing deployment process for $($runbook.Name)"
        $destinationRunbookProcess.Steps = Copy-OctopusDeploymentProcess -sourceChannelList $sourceChannelList -destinationChannelList $destinationChannelList -sourceData $sourceData -destinationData $destinationData -sourceDeploymentProcessSteps $sourceRunbookProcess.Steps -destinationDeploymentProcessSteps $destinationRunbookProcess.Steps
            
        Save-OctopusApiItem -Item $destinationRunbookProcess -Endpoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/runbookProcesses" -ApiKey $destinationData.OctopusApiKey    
    }
}

function Copy-OctopusProjectVariables
{
    param(
        $sourceChannelList,
        $destinationChannelList,
        $destinationProject,        
        $sourceProject,
        $sourceData,
        $destinationData,
        $cloneScriptOptions,
        $createdNewProject
    )
    
    $canProceed = $createdNewProject
    if ($canProceed -eq $false)
    {
        $canProceed = Get-UserCloneDecision -message "This is an existing project.  Would you like me to clone the project $($destinationProject.Name) variables? Y/N"
    }

    if ($canProceed)
    {
        $sourceVariableSetVariables = Get-OctopusApi -EndPoint "$($sourceData.OctopusUrl)/$($sourceProject.Links.Variables)" -ApiKey $sourceData.OctopusApiKey 
        $destinationVariableSetVariables = Get-OctopusApi -EndPoint "$($destinationData.OctopusUrl)/$($destinationProject.Links.Variables)" -ApiKey $destinationData.OctopusApiKey

        $SourceProjectData = @{
            ChannelList = $sourceChannelList;
            RunbookList = Get-OctopusApiItemList -EndPoint "$($SourceData.OctopusUrl)/api/$($sourceData.SpaceId)/projects/$($sourceProject.Id)/runbooks" -ApiKey $sourcedata.OctopusApiKey;
            Project = $sourceProject    
        }
        $DestinationProjectData = @{
            ChannelList = $destinationChannelList;
            RunbookList = Get-OctopusApiItemList -EndPoint "$($DestinationData.OctopusUrl)/api/$($DestinationData.SpaceId)/projects/$($destinationProject.Id)/runbooks" -ApiKey $destinationData.OctopusApiKey
            Project = $destinationProject
        }

        Write-CleanUpOutput "Cloning variables for project $($destinationProject.Name)"

        Copy-OctopusVariableSetValues -SourceVariableSetVariables $sourceVariableSetVariables -DestinationVariableSetVariables $destinationVariableSetVariables -SourceData $SourceData -DestinationData $DestinationData -SourceProjectData $SourceProjectData -DestinationProjectData $DestinationProjectData -CloneScriptOptions $cloneScriptOptions
    }
}

function Copy-OctopusProjects
{
    param(
        $SourceData,
        $DestinationData,
        $CloneScriptOptions
    )    

    $filteredList = Get-OctopusFilteredList -itemList $sourceData.ProjectList -itemType "Projects" -filters $cloneScriptOptions.ProjectsToClone

    foreach($project in $filteredList)
    {
        $createdNewProject = Copy-OctopusProject -sourceData $SourceData -destinationData $DestinationData -sourceProject $project               
        
        Write-GreenOutput "Reloading destination projects"        
        
        $destinationData.ProjectList = Get-OctopusProjectList -ApiKey $destinationData.OctopusApiKey -OctopusServerUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId       

        $destinationProject = Get-OctopusItemByName -ItemList $DestinationData.ProjectList -ItemName $project.Name

        if ($null -ne $destinationProject)
        {
            $sourceChannels = Get-OctopusApiItemList -EndPoint "$($SourceData.OctopusUrl)/api/$($SourceData.SpaceId)/projects/$($project.Id)/channels" -ApiKey $SourceData.OctopusApiKey
            $destinationChannels = Get-OctopusApiItemList -EndPoint "$($DestinationData.OctopusUrl)/api/$($DestinationData.SpaceId)/projects/$($destinationProject.Id)/channels" -ApiKey $DestinationData.OctopusApiKey

            Copy-OctopusProjectChannels -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -destinationProject $destinationProject -sourceData $SourceData -destinationData $DestinationData
            Copy-OctopusProjectDeploymentProcess -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -destinationProject $destinationProject -sourceData $SourceData -destinationData $DestinationData 
            Copy-OctopusProjectRunbooks -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -destinationProject $destinationProject -sourceProject $project -destinationData $DestinationData -sourceData $SourceData            
            Copy-OctopusProjectVariables -sourceChannelList $sourceChannels -destinationChannelList $destinationChannels -destinationProject $destinationProject -sourceProject $project -destinationData $DestinationData -sourceData $SourceData -cloneScriptOptions $CloneScriptOptions -createdNewProject $createdNewProject
        }
        else
        {
            Write-YellowOutput "I could not find the project $($project.Name) in the destination.  Most likely you opted to skip it.  No worries, I'm moving onto the next project"
        }
    }
}

function Copy-OctopusTenants
{
    param(
        $sourceData,
        $destinationData,
        $CloneScriptOptions
    )

    Write-GreenOutput "Cloning tenants"
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.TenantList -itemType "Tenants" -filters $cloneScriptOptions.TenantsToClone

    foreach($tenant in $filteredList)
    {
        $matchingTenant = Get-OctopusItemByName -ItemName $tenant.Name -ItemList $destinationData.TenantList

        if ($null -eq $matchingTenant)
        {
            Write-GreenOutput "The tenant $($tenant.Name) doesn't exist on the source, copying over."
            $tenantToAdd = Copy-OctopusObject -ItemToCopy $tenant
            $tenantToAdd.Id = $null
            $tenantToAdd.SpaceId = $destinationData.SpaceId
            $tenantToAdd.ProjectEnvironments = @{}

            foreach($key in $tenant.ProjectEnvironments.GetEnumerator())
            {
                Write-VerboseOutput "Attempting to matching $key with source"
                $matchingProjectId = Convert-SourceIdToDestinationId -SourceList $sourceData.ProjectList -DestinationList $destinationData.ProjectList -IdValue $key

                Write-VerboseOutput "Attempting to match the environment list with source"
                $scopedEnvironments = Convert-SourceIdListToDestinationIdList -SourceList $sourceData.EnvironmentList -DestinationList $destinationData.EnvironmentList -IdList $tenant[$key]

                if ($scopedEnvironments.Length -gt 0 -and $null -ne $matchingProjectId)
                {
                    Write-VerboseOutput "The matching environments were found and matching project was found, let's scope it to the tenant"
                    $tenantToAdd.ProjectEnvironments[$matchingProjectId] = $scopedEnvironments
                }
            }

            Save-OctopusApiItem -Item $tenantToAdd -Endpoint "$($destinationData.OctopusUrl)/api/$($destinationData.SpaceId)/tenants" -ApiKey $destinationData.OctopusApiKey
        }
        else
        {
            Write-GreenOutput "The tenant $($tenant.Name) already exists on the source, skipping."
        }
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

    Write-GreenOutput "Getting Space Information from $octopusUrl"
    $octopusData.SpaceList = Get-OctopusSpaceList -OctopusServerUrl $octopusUrl -ApiKey $octopusApiKey
    $octopusData.Space = Get-OctopusItemByName -ItemList $octopusData.SpaceList -ItemName $spaceName
    $octopusData.SpaceId = $octopusData.Space.Id

    if ($null -eq $octopusData.Space)
    {
        Throw "Unable to find space $spaceName on $octopusUrl please confirm it exists and try again."
    }

    Write-GreenOutput "Getting Environments for $spaceName in $octopusUrl"
    $octopusData.EnvironmentList = Get-OctopusEnvironmentList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

    Write-GreenOutput "Getting Worker Pools for $spaceName in $octopusUrl"
    $octopusData.WorkerPoolList = Get-OctopusWorkerPoolList -ApiKey $octopusApiKey -OctopusServerUrl $octopusUrl -SpaceId $octopusData.SpaceId

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