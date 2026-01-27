<#
    Module: XmPlaylist
    Description: PowerShell module for accessing xmplaylist.com API
    Date: 2026.01.26
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
    .EXAMPLE
    Get-XMStation
    Retrieves and displays all SiriusXM stations.
    .NOTES
    https://xmplaylist.com/api/station

    #>

    $url = "https://xmplaylist.com/api/station"
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" }
    return $response

}


function Get-Playlist{
    <#
    .SYNOPSIS
    Retrieves the playlist for a specified SiriusXM channel.
    .DESCRIPTION
    This function calls the xmplaylist.com API endpoint `/api/station/{channel}` to fetch the playlist for the specified SiriusXM channel.
    It supports pagination to retrieve multiple pages of results based on the provided limit parameter.
    .PARAMETER Channel
    The 'deeplink' name of the SiriusXM channel (e.g., "siriusxmhits1"). 
    Use Get-XMStation to retrieve a list of available channels.
    .PARAMETER Limit
    The number of pages to retrieve. Each page contains a set of playlist items. Default is 1.
    .EXAMPLE
    Get-XMPlaylist siriusxmhits1
    Retrieves recently played tracks for the "siriusxmhits1" channel
    .EXAMPLE
    Get-XMPlaylist -Channel "siriusxmhits1/newest" 
    Retrieves the newest tracks for the "siriusxmhits1" channel
    .EXAMPLE
    Get-XMPlaylist -Channel "siriusxmhits1/most-heard" -Limit 3
    Retrieves the top 3 pages of most-heard tracks for the "siriusxmhits1" channel
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Channel,
        [Parameter(Mandatory = $false)]
        [int]$Limit = 1
        )


    $url = "https://xmplaylist.com/api/station/$Channel"
    $allResults = @()

    try 
    {
        while ($Limit -gt 0 -and $url) 
        {
            $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" }
            $allResults += $response.results
            $url = $response.next
            $Limit--
        }

        return $allResults
    } 
    catch     
    {
        Write-Error "Failed to retrieve data for channel '$Channel'. $_"
    }
}


function Format-Playlist {
    <#
    .SYNOPSIS
    Formats a playlist item into a custom object with artist, title, link and timestamp.
    .DESCRIPTION
    This function takes a playlist item object (as returned by Get-XMPlaylist) and extracts key information such as artist, title, link, and timestamp.
    It returns a custom PowerShell object with these properties for easier consumption.
    .PARAMETER Item
    The playlist item object to process.
    .PARAMETER Site
    The site to extract the link from (e.g., 'youtube', 'spotify'). Default is 'youtube'.
    .EXAMPLE
    Get-Playlist siriusxmhits1 | Format-XMPlaylist
    Format and display the playlist items for the siriusxmhits1 station.

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$Items,

        [Parameter(Mandatory = $false)]
        [string]$Site = 'youtube'  # Default site for link extraction (e.g., 'youtube', 'spotify')
    )

    # Process each item in the collection
    begin {
        $formattedItems = @()
    }
    process {
        foreach ($Item in $Items) {
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


Export-ModuleMember -Function Get-Station, Get-Playlist, Format-Playlist