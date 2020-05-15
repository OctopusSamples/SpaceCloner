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

            $accountClone = Copy-OctopusObject -ItemToCopy $account -ClearIdValue $true -SpaceId $DestinationData.SpaceId
            
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

            Save-OctopusApiItem -Item $accountClone -Endpoint "accounts" -ApiKey $DestinationData.OctopusApiKey -OctopusUrl $DestinationData.OctopusUrl -SpaceId $DestinationData.SpaceId
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