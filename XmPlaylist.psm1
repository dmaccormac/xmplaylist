<#
    Module: XmPlaylist
    Description: PowerShell module for accessing xmplaylist.com API
    Date: 2025-10-03
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
    
    .EXAMPLE
    $(Get-XMStation).results | Select-Object -Property number, name, shortDescription

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
    Get recently played tracks for SiriusXM channel.

    .DESCRIPTION
    This function calls the xmplaylist.com API endpoint `/api/station/{channel}` to fetch playlist information. 
    If no channel is specified, it retrieves recently played tracks for all channels.

    .PARAMETER Channel
    The 'deeplink' name of the SiriusXM channel (e.g., "siriusxmhits1"). 
    Use Get-XMStation to retrieve a list of available channels.

    .EXAMPLE
    Get-XMPlaylist  # Retrieves the general feed (recently played, all channels)

    .EXAMPLE
    Get-XMPlaylist siriusxmhits1 # Retrieves recently played tracks for the "siriusxmhits1" channel

    .EXAMPLE
    Get-XMPlaylist -Channel "siriusxmhits1/newest" # Retrieves the newest tracks for the "siriusxmhits1" channel

    .EXAMPLE
    Get-XMPlaylist -Channel "siriusxmhits1/most-heard" # Retrieves the most-heard tracks for the "siriusxmhits1" channel

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Channel
        )


    $url = "https://xmplaylist.com/api/feed"

    if ($Channel) {
    $url = "https://xmplaylist.com/api/station/$Channel"
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" }
        return $response
    } catch {
        Write-Error "Failed to retrieve data for channel '$Channel'. $_"
    }
}


function Format-PlaylistItem {
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
    $playlist = (Get-XMPlaylist siriusxmhits1).results | ForEach-Object { $_ | Format-XMPlaylistItem}

    Create $playlist item containing recently played items for siriusxmhits1 station.

    .EXAMPLE
    $playlist | ForEach-Object { 
        yt-dlp -t mp3 "$($_.Link)" -o "$($_.Artist) - $($_.Title).%(ext)s" 
    }
    
    Download all playlist items in mp3 format using yt-dlp.

    .EXAMPLE
    $playlist | ForEach-Object {
        Write-Host -ForegroundColor Yellow "[xmplaylist] $($_.Artist) - $($_.Title)"
        cmd /c "yt-dlp.exe -f bestaudio `"$($_.Link)`" -o - | ffplay -nodisp -autoexit -i -"
    }

    Play all playlist items using yt-dlp and ffplay.
    It is necessary use cmd here due to pipeline handling in PowerShell.

    #>

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$Item,

        [Parameter(Mandatory = $false)]
        [string]$Site = 'youtube'  # Default site for link extraction (e.g., 'youtube', 'spotify')
    )


    $artist = if ($Item.track.artists) { $Item.track.artists -join ', ' } else { 'Unknown' }
    $title = if ($Item.track.title) { $Item.track.title } else { 'Unknown' }
    $time = if ($Item.timestamp) { ([datetime]::Parse($Item.timestamp)).ToLocalTime() } else { 'Unknown' }

    $link = if ($Item.links) { ($Item.links | Where-Object { $_.site -eq $Site } | Select-Object -First 1).url } else { $null }

    return [PSCustomObject]@{
        Artist = $artist
        Title  = $title
        Link   = $link
        Timestamp = $time
        
    }
}


Export-ModuleMember -Function Get-Station, Get-Playlist, Format-PlaylistItem
