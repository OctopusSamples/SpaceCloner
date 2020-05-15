function Get-OctopusUrl
{
    param (
        $EndPoint,        
        $SpaceId,
        $OctopusUrl
    )  

    if ($EndPoint -match "/api")
    {        
        return "$OctopusUrl/$endPoint"
    }
    
    if ([string]::IsNullOrWhiteSpace($SpaceId))
    {
        return "$OctopusUrl/api/$EndPoint"
    }
    
    return "$OctopusUrl/api/$spaceId/$EndPoint"
}

Function Get-OctopusApiItemList
{
    param (
        $EndPoint,
        $ApiKey,
        $SpaceId,
        $OctopusUrl
    )    

    $url = Get-OctopusUrl -EndPoint $EndPoint -SpaceId $SpaceId -OctopusUrl $OctopusUrl

    Write-VerboseOutput "Invoking $url"

    $results = Invoke-RestMethod -Method Get -Uri $url -Headers @{"X-Octopus-ApiKey"="$ApiKey"}   
    
    Write-VerboseOutput "$url returned a list with $($results.Items.Length) item(s)" 

    return $results.Items
}

Function Get-OctopusApi
{
    param (
        $EndPoint,
        $ApiKey,
        $SpaceId,
        $OctopusUrl
    )    

    $url = Get-OctopusUrl -EndPoint $EndPoint -SpaceId $SpaceId -OctopusUrl $OctopusUrl

    Write-VerboseOutput "Invoking GET $url"

    $results = Invoke-RestMethod -Method Get -Uri $url -Headers @{"X-Octopus-ApiKey"="$ApiKey"}    

    return $results
}

Function Save-OctopusApi
{
    param (
        $EndPoint,
        $ApiKey,
        $Method,
        $Item,
        $SpaceId,
        $OctopusUrl
    )

    $url = Get-OctopusUrl -EndPoint $EndPoint -SpaceId $SpaceId -OctopusUrl $OctopusUrl

    Write-VerboseOutput "Invoking $Method $url"

    if ($null -eq $item)
    {
        $results = Invoke-RestMethod -Method $Method -Uri $url -Headers @{"X-Octopus-ApiKey"="$ApiKey"}
    }
    else
    {
        $bodyAsJson = ConvertTo-Json $Item -Depth 10
        Write-VerboseOutput "Going to invoke $Method $url with the following body"
        Write-VerboseOutput $bodyAsJson

        $results = Invoke-RestMethod -Method $Method -Uri $url -Headers @{"X-Octopus-ApiKey"="$ApiKey"} -Body $bodyAsJson
    }

    return $results
}

function Save-OctopusApiItem
{
    param(
        $Item,
        $Endpoint,
        $ApiKey,
        $SpaceId,
        $OctopusUrl
    )    

    $method = "POST"

    if ($null -ne $Item.Id)    
    {
        Write-VerboseOutput "Item has id, updating method call to PUT"
        $method = "Put"
        $endPoint = "$endPoint/$($Item.Id)"
    }
    
    $results = Save-OctopusApi -EndPoint $Endpoint $method $method -Item $Item -ApiKey $ApiKey -OctopusUrl $OctopusUrl -SpaceId $SpaceId

    Write-VerboseOutput $results

    return $results
}