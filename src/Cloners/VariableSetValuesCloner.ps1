. ($PSScriptRoot + ".\..\Core\Logging.ps1")
. ($PSScriptRoot + ".\..\Core\Util.ps1")

. ($PSScriptRoot + ".\..\DataAccess\OctopusDataAdapter.ps1")
. ($PSScriptRoot + ".\..\DataAccess\OctopusDataFactory.ps1")

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
            if ($destinationData.HasRunbooks)
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
            else 
            {
                $octopusVariable.Scope.PSObject.Properties.Remove('ProcessOwner')    
            }
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
            Write-YellowOutput "The variable $variableName already exists on destination. You selected to skip duplicate instances, skipping."
        }
        elseif ($octopusVariable.Type -eq "AmazonWebServicesAccount" -and $destinationData.HasAWSSupport -eq $false)
        {
            Write-YellowOutput "The variable $variableName is an AWS Account Type, the destination does not support that variable type, skipping."
        }
        elseif ($octopusVariable.Type -eq "AzureAccount" -and $destinationData.HasAzureVariableTypeSupport -eq $false)
        {
            Write-YellowOutput "The variable $variableName is an Azure Account Type, the destination does not support that variable type, skipping."
        }
        elseif ($octopusVariable.Type -eq "WorkerPool" -and $destinationData.HasWorkerPoolVariableTypeSupport -eq $false)
        {
            Write-YellowOutput "The variable $variableName is a WorkerPool Type, the destination does not support that variable type, skipping."
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
        elseif ($foundIndex -gt -1)
        {
            $DestinationVariableSetVariables.Variables[$i].Value = $octopusVariable.Value
            if ($octopusVariable.Value -eq "Dummy Value")         
            {                
                Write-CleanUpOutput "The variable $variableName is a sensitive variable, value set to 'Dummy Value'"
            }
        }        
    }

    Save-OctopusApi -OctopusUrl $DestinationData.OctopusUrl -SpaceId $null -EndPoint $DestinationVariableSetVariables.Links.Self -ApiKey $DestinationData.OctopusApiKey -Method "PUT" -Item $DestinationVariableSetVariables
    Write-GreenOutput "Variables successfully cloned."
}