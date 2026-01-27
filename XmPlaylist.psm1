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
    
    [CmdletBinding()]
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


function Invoke-PlaylistItem {
    <#
    .SYNOPSIS
    Plays a track using yt-dlp and ffplay.

    .DESCRIPTION
    This function takes an XMPlaylistItem containing a YouTube link and plays the track using yt-dlp to fetch the audio and ffplay to play it.
    
    .PARAMETER Item
    The formatted playlist item to play.
   
    .PARAMETER OutputFile
    (Optional) If specified, saves the audio to the given file path instead of playing it. Default is "Artist - Title.mp3".
    
    .PARAMETER Quiet
    If specified, suppresses yt-dlp and ffplay output.
    
    .EXAMPLE
    $(Get-XMPlaylist siriusxmhits1).results | ForEach-Object { 
        Invoke-XMPlaylistItem (Format-XMPlaylistItem $_) -Quiet 
    }

    Plays all recently played items for the siriusxmhits1 station. Suppresses output from yt-dlp and ffplay.
    
    
    .EXAMPLE
    $(Get-XMPlaylist siriusxmhits1).results | ForEach-Object { 
        $formattedItem = Format-XMPlaylistItem $_
        $outputFile = "$($formattedItem.Artist) - $($formattedItem.Title).mp3"
        Invoke-XMPlaylistItem -Item $formattedItem -OutputFile $outputFile
    }

    Saves all recently played items for the siriusxmhits1 station to mp3 files.

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$Item,
        [Parameter(Mandatory = $false)]
        [string]$OutputFile,
        [Parameter(Mandatory = $false)]
        [switch]$Quiet
    )

        # Check if yt-dlp.exe and ffplay.exe are available
        if (-not (Get-Command yt-dlp.exe -ErrorAction SilentlyContinue)) {
            Write-Error "yt-dlp.exe not found in PATH. Please install yt-dlp and ensure it is in your system PATH."
            return
        }
        if (-not (Get-Command ffplay.exe -ErrorAction SilentlyContinue)) {
            Write-Error "ffplay.exe not found in PATH. Please install ffplay and ensure it is in your system PATH."
            return
        }

        $redirect = if ($Quiet) { "2> NUL" } else { "" }
        Write-Host -ForegroundColor Yellow "[xmplaylist] $($Item.Artist) - $($Item.Title)"
        if ($OutputFile) {
            cmd /c "yt-dlp.exe -t mp3 `"$($Item.Link)`" -o `"$OutputFile`" $redirect"
        } else {
            cmd /c "yt-dlp.exe --no-progress -f bestaudio `"$($Item.Link)`" -o - $redirect | ffplay -nodisp -autoexit -i - $redirect"
        }
}

Export-ModuleMember -Function Get-Station, Get-Playlist, Format-PlaylistItem, Invoke-PlaylistItem