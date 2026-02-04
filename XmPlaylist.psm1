<#
    Module: XmPlaylist
    Description: PowerShell module for accessing xmplaylist.com API
    Date: 2026.02.03
    Author: Dan MacCormac <dmaccormac@gmail.com>
    Website: https://github.com/dmaccormac/XmPlaylist
    API Reference: https://xmplaylist.com/api/documentation
#>

function Get-Station {
    <#
    .SYNOPSIS
    Retrieves a list of all SiriusXM stations.
    .DESCRIPTION
    This function calls the xmplaylist.com API endpoint `/api/station` to fetch a list of all available SiriusXM stations.
    .PARAMETER Raw
    If specified, returns the raw API response without conversion.
    .EXAMPLE
    Get-XMStation
    Retrieves and displays all SiriusXM stations.
    .NOTES
    https://xmplaylist.com/api/station

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$Raw=$false
        )

    $url = "https://xmplaylist.com/api/station"
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" }
    #return $($response | ConvertFrom-ApiStation)

    if ($Raw) { return $response }
    return (ConvertFrom-ApiStation $response)
    

}


function Get-Playlist{
    <#
    .SYNOPSIS
    Retrieves the playlist for a specified SiriusXM channel.
    .DESCRIPTION
    This function calls the xmplaylist.com API endpoint `/api/station/{channel}` to fetch the playlist for the specified SiriusXM channel.
    .PARAMETER Channel
    The 'deeplink' name of the SiriusXM channel (e.g., "siriusxmhits1"). 
    Use Get-XMStation to retrieve a list of available channels.
    .PARAMETER Link
    The site to extract the link from (e.g., 'youtube', 'spotify'). Default is 'youtube'.
    Available sites include: amazon, amazonMusic, spotify, appleMusic, itunes, tidal, youtube, youtubeMusic, spotify, soundcloud, deezer, qobuz, pandora.  
    .PARAMETER PageCount
    The number of pages to retrieve. Each page contains 24 items. Default setting is 1 page.
    .PARAMETER Raw
    If specified, returns the raw API response without conversion.
    .EXAMPLE
    Get-XMPlaylist siriusxmhits1
    Retrieves recently played tracks for the "siriusxmhits1" channel    
    .EXAMPLE
    Get-XMPlaylist -Channel "siriusxmhits1/newest" 
    Retrieves the newest tracks for the "siriusxmhits1" channel    
    .EXAMPLE
    Get-XMPlaylist -Channel "siriusxmhits1/most-heard" -PageCount 3
    Retrieves the top 3 pages of most-heard tracks for the "siriusxmhits1" channel
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Channel,
        [Parameter(Mandatory = $false)]
        [string]$Link = 'youtube',
        [Parameter(Mandatory = $false)]
        [int]$PageCount = 1,
        [Parameter(Mandatory = $false)]
        [switch]$Raw = $false
        )


    $url = "https://xmplaylist.com/api/station/$Channel"
    $allResults = @()

    try 
    {
        while ($PageCount -gt 0 -and $url) 
        {
            $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" }
                        
            if ($Raw) {$allResults += $response} 
            else {$allResults += (ConvertFrom-ApiPlaylist -Items $response -Site $Link)}
            
            $url = $response.next
            $PageCount--
            Start-Sleep -Milliseconds 200  # To avoid hitting rate limits
        }

        return $allResults 
    } 
    catch     
    {
        Write-Error "Failed to retrieve data for channel '$Channel'. $_"
    }
}


function ConvertFrom-ApiPlaylist {
    <#
    .SYNOPSIS
    Converts playlist items from API format to a custom object.
    .DESCRIPTION
    This function takes a playlist item object (as returned by Get-XMPlaylist) and extracts key information such as artist, title, link, and timestamp.
    It returns a custom PowerShell object with these properties for easier consumption.
    .PARAMETER Item
    The playlist item object to process.
    .PARAMETER Site
    The site to extract the link from (e.g., 'youtube', 'spotify'). Default is 'youtube'.
    .EXAMPLE
    Get-Playlist siriusxmhits1 | ConvertFrom-ApiPlaylist
    Converts the API response returned from Get-Playlist.

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$Items,

        [Parameter(Mandatory = $false)]
        [string]$Site = 'youtube' 
    )

    # Process each item in the collection
    begin {
        $formattedItems = @()
    }
    process {
        foreach ($Item in $Items.results) {
            $artist = if ($Item.track.artists) { $Item.track.artists -join ', ' } else { 'Unknown' }
            $title = if ($Item.track.title) { $Item.track.title } else { 'Unknown' }
            $time = if ($Item.timestamp) { ([datetime]::Parse($Item.timestamp)).ToLocalTime() } else { 'Unknown' }

            $link = if ($Item.links) { ($Item.links | Where-Object { $_.site -eq $Site } | Select-Object -First 1).url } else { $null }

            $formattedItem = [PSCustomObject]@{
                Artist    = $artist
                Title     = $title
                Link      = $link
                Timestamp = $time
            }

            $formattedItems += $formattedItem
        }
    }
    end {
        return $formattedItems
    }
}

function ConvertFrom-ApiStation {
    <#
    .SYNOPSIS
    Converts station items from API format to a custom object.
    .DESCRIPTION
    This function takes a station item object (as returned by Get-XMStation) and extracts key information such as number, name, and description.
    It returns a custom PowerShell object with these properties for easier consumption.
    .PARAMETER Item
    The station item object to process.
    .EXAMPLE
    Get-Station | ConvertFrom-ApiStation
    Converts the API response returned from Get-Station.
 #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$Items
    )

    # Process each item in the collection
    begin {
        $formattedItems = @()
    }
    process {
        foreach ($Item in $Items.results) {
            $number = if ($Item.number) { $Item.number } else { 'Unknown' }
            $name = if ($Item.name) { $Item.name } else { 'Unknown' }
            $description = if ($Item.shortDescription) { $Item.shortDescription } else { 'Unknown' }
            $deeplink = if ($Item.deeplink) { $Item.deeplink } else { 'Unknown' }

            $formattedItem = [PSCustomObject]@{
                Number      = $number
                Deeplink    = $deeplink
                Name        = $name
                Description = $description

            }

            $formattedItems += $formattedItem
        }
    }
    end {
        return $formattedItems
    }

}


Export-ModuleMember -Function Get-Station, Get-Playlist