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
        if ((Get-OctopusAccountTypeSupportedOnDestination -account $account -destinationData $DestinationData) -eq $false)
        {
            continue
        }        

        $matchingAccount = Get-OctopusItemByName -ItemName $account.Name -ItemList $DestinationData.InfrastructureAccounts

        if ($null -eq $matchingAccount)
        {
            Write-GreenOutput "The account $($account.Name) does not exist.  Creating it."

            $accountClone = Copy-OctopusObject -ItemToCopy $account -ClearIdValue $true -SpaceId $DestinationData.SpaceId

            $accountClone.EnvironmentIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.EnvironmentList -DestinationList $DestinationData.EnvironmentList -IdList $accountClone.EnvironmentIds            
            $accountClone.TenantIds = Convert-SourceIdListToDestinationIdList -SourceList $SourceData.TenantList -DestinationList $DestinationData.TenantList -IdList $accountClone.TenantIds
            
            Convert-OctopusAWSAccountInformation -accountClone $accountClone
            Convert-OctopusAzureServicePrincipalAccount -accountClone $accountClone
            Convert-OctopusTokenAccount -accountClone $accountClone                                
            Convert-OctopusAccountTenantedDeploymentParticipation -accountClone $accountClone                       

            Save-OctopusApiItem -Item $accountClone -Endpoint "accounts" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId            
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

function Get-OctopusAccountTypeSupportedOnDestination
{
    param (
        $account,
        $destinationData
    )

    if ($accountClone.AccountType -eq "AmazonWebServicesAccount" -and $destinationData.HasAWSSupport -eq $false)
    {
        Write-YellowOutput -Message "The account $($Account.Name) is an $($action.AccountType), which isn't supported by the destination, skipping"
        return $false
    }

    if ($accountClone.AccountType -eq "Token" -and $destinationData.HasTokenSupport -eq $false)
    {
        Write-YellowOutput -Message "The account $($Account.Name) is an $($action.AccountType), which isn't supported by the destination, skipping"
        return $false
    }

    return $true
}

function Convert-OctopusAWSAccountInformation
{
    param ($accountClone)

    if ($accountClone.AccountType -ne "AmazonWebServicesAccount")
    {
        return
    } 

    $accountClone.AccessKey = "AKIABCDEFGHI3456789A"
    $accountClone.SecretKey.HasValue = $false
    $accountClone.SecretKey.NewValue = "DUMMY VALUE DUMMY VALUE"    
}

function Convert-OctopusAzureServicePrincipalAccount
{
    param ($accountClone)

    if ($accountClone.AccountType -ne "AzureServicePrincipal")
    {
        return
    }

    $accountClone.SubscriptionNumber = New-Guid
    $accountClone.ClientId = New-Guid
    $accountClone.TenantId = New-Guid
    $accountClone.Password.HasValue = $false
    $accountClone.Password.NewValue = "DUMMY VALUE DUMMY VALUE"    
}

function Convert-OctopusTokenAccount
{
    param ($accountClone)

    if($accountClone.AccountType -ne "Token")
    {
        return
    }

    $accountClone.Token.HasValue = $false
    $accountClone.Token.NewValue = "DUMMY VALUE"                    
}

function Convert-OctopusAccountTenantedDeploymentParticipation
{
    param ($accountClone)

    if ($accountClone.TenantIds.Length -eq 0)
    {
        $accountClone.TenantedDeploymentParticipation = "Untenanted"
    }
}