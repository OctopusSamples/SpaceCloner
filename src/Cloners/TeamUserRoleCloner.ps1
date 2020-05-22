function Copy-OctopusSpaceTeamUserRoles
{
    param(
        $sourceData,
        $destinationData,
        $cloneScriptOptions
    )

    if ($cloneScriptOptions.CloneTeamUserRoleScoping -eq $false)
    {
        Write-Warning "The option CloneTeamUserRoleScoping was set to false, skipping cloning the team user roles"
        return
    }
    
    $filteredList = Get-OctopusFilteredList -itemList $sourceData.TeamList -itemType "Space Teams User Role Scoping" -filters $cloneScriptOptions.SpaceTeamsToClone        
    
    if ($filteredList.length -eq 0)
    {
        return
    }    

    Write-OctopusPostCloneCleanUpHeader "*************Starting Teams User Roles*************"
    foreach ($team in $filteredList)
    {
        if ($null -eq $team.SpaceId)
        {
            Write-OctopusVerbose "The team $($team.Name) is a space team, skipping"
            continue
        }

        Write-OctopusVerbose "Starting clone of team $($team.Name)"
        
        $matchingItem = Get-OctopusItemByName -ItemName $team.Name -ItemList $destinationData.teamList                

        If ($null -eq $matchingItem)
        {
            Write-OctopusVerbose "Team $($team.Name) does not exist in destination, skipping"    
            continue
        }

        Write-OctopusVerbose "Team $($team.Name) was found in the destination, updating the scoping"                    

        $sourceUserRoleScoping = Get-OctopusApiItemList -endPoint "teams/$($team.Id)/scopeduserroles?skip=0&take=1000" -apiKey $sourceData.OctopusApiKey -spaceId $null -OctopusUrl $sourceData.OctopusUrl
        $destinationUserRoleScoping = Get-OctopusApiItemList -endPoint "teams/$($matchingItem.Id)/scopeduserroles?skip=0&take=1000" -apiKey $destinationData.OctopusApiKey -spaceId $null -OctopusUrl $destinationData.OctopusUrl
        
        if ($destinationUserRoleScoping.Length -gt 0)
        {
            Write-OctopusVerbose "The team $($team.Name) in the destination already has user roles scoped to them, skipping"
            continue
        }

        foreach ($role in $sourceUserRoleScoping)
        {
            $copyOfItemToClone = Copy-OctopusObject -ItemToCopy $role -SpaceId $destinationData.SpaceId -ClearIdValue $true      

            $copyOfItemToClone.UserRoleId = Convert-SourceIdToDestinationId -sourceList $sourceData.UserRoleList -destinationList $sourceData.UserRoleList -idValue $role.UserRoleId            
            $copyOfItemToClone.TeamId = $matchingItem.Id
            $copyOfItemToClone.ProjectIds = @(Convert-SourceIdListToDestinationIdList -SourceList $sourceData.ProjectList -DestinationList $destinationData.ProjectList -IdList $role.ProjectIds) 
            $copyOfItemToClone.EnvironmentIds = @(Convert-SourceIdListToDestinationIdList -SourceList $sourceData.EnvironmentList -DestinationList $destinationData.EnvironmentList -IdList $role.EnvironmentIds) 
            $copyOfItemToClone.TenantIds = @(Convert-SourceIdListToDestinationIdList -SourceList $sourceData.TenantList -DestinationList $destinationData.TenantList -IdList $role.TenantIds) 
            $copyOfItemToClone.ProjectGroupIds = @(Convert-SourceIdListToDestinationIdList -SourceList $sourceData.ProjectGroupList -DestinationList $destinationData.ProjectGroupList -IdList $role.ProjectGroupIds) 

            if ($null -ne $copyOfItemToClone.RoleId)
            {
                Save-OctopusApiItem -Item $copyOfItemToClone `
                    -Endpoint "scopeduserroles" `
                    -ApiKey $destinationData.OctopusApiKey `
                    -SpaceId $null `
                    -OctopusUrl $destinationData.OctopusUrl 
            }           
            else
            {
                Write-OctopusVerbose "There is no matching role for $($role.UserRoleId), skipping this scoping"    
            }
        }                            

        Write-OctopusPostCloneCleanUp "Role Scoping was created for $($team.Name), please verify it looks correct."        
    }

    Write-OctopusPostCloneCleanUpHeader "*************End Teams User Roles******************"

    Write-OctopusSuccess "User scoped roles successfully cloned to teams"        
}
