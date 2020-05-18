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
        Write-GreenOutput "Starting clone of tenant $($tenant.Name)"
        
        $matchingTenant = Get-OctopusItemByName -ItemName $tenant.Name -ItemList $destinationData.TenantList

        if ($null -eq $matchingTenant)
        {
            Write-GreenOutput "The tenant $($tenant.Name) doesn't exist on the source, copying over."
            $tenantToAdd = Copy-OctopusObject -ItemToCopy $tenant -ClearIdValue $true -SpaceId $destinationData.SpaceId
            $tenantToAdd.Id = $null
            $tenantToAdd.SpaceId = $destinationData.SpaceId
            $tenantToAdd.ProjectEnvironments = @{}            

            $tenant.ProjectEnvironments.PSObject.Properties | ForEach-Object {
                Write-VerboseOutput "Attempting to matching $($_.Name) with source"
                $matchingProjectId = Convert-SourceIdToDestinationId -SourceList $sourceData.ProjectList -DestinationList $destinationData.ProjectList -IdValue $_.Name

                Write-VerboseOutput "Attempting to match the environment list with source"
                $scopedEnvironments = Convert-SourceIdListToDestinationIdList -SourceList $sourceData.EnvironmentList -DestinationList $destinationData.EnvironmentList -IdList $_.Value

                if ($scopedEnvironments.Length -gt 0 -and $null -ne $matchingProjectId)
                {
                    Write-VerboseOutput "The matching environments were found and matching project was found, let's scope it to the tenant"
                    $tenantToAdd.ProjectEnvironments[$matchingProjectId] = @($scopedEnvironments)
                }
            }            

            Save-OctopusApiItem -Item $tenantToAdd -Endpoint "tenants" -ApiKey $destinationData.OctopusApiKey -OctopusUrl $destinationData.OctopusUrl -SpaceId $destinationData.SpaceId
        }
        else
        {
            Write-GreenOutput "The tenant $($tenant.Name) already exists on the source, skipping."
        }
    }
}