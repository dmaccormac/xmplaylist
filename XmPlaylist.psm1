<#
    Module: XmPlaylist [experimental]
    Description: PowerShell module for accessing xmplaylist.com API
    Created: 2023-09-21
    Last Updated: 2025-10-06
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
    $item = $(Get-XMPlaylist).results | Select-Object -First 1
    $processed = Format-XMPlaylistItem -Item $item
    $processed | Format-Table

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

function Start-Playlist {

    <#
    .SYNOPSIS
    Plays a playlist of tracks using yt-dlp and ffplay.
    .DESCRIPTION
    This function takes a takes a SiriusXM channel name, retrieves its playlist using Get-XMPlaylist, formats each item with Format-XMPlaylistItem, and plays each track using Invoke-Track.
    .PARAMETER Channel
    The SiriusXM channel to play. This is used to fetch the playlist.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Channel 
    ) 


        $Playlist = Get-XMPlaylist -Channel $Channel | Select-Object -ExpandProperty results | ForEach-Object { $_ | Format-XMPlaylistItem }
        Write-Output $Playlist | Format-Table -AutoSize


        foreach ($item in $Playlist) {
            if (-not $item.Link) {
                Write-Warning "No link available for $($item.Artist) - $($item.Title). Skipping."
                continue
            }
            Invoke-Track $item
        }

}

function Show-Player {
    <#
    .SYNOPSIS
    Displays list of available stations and allows user to select one to play.

    .DESCRIPTION
    This function retrieves the list of available SiriusXM stations, displays them in a grid view for user selection, and then starts playing the selected station's playlist.

    .EXAMPLE
    Show-XMPlaylist

    #>

    $stationList = $(Get-XMStation).results | Select-Object number, name, deeplink, shortdescription
    $selectedStation = $stationList | Out-GridView -Title "Available Stations" -PassThru
    Start-Playlist -Channel $selectedStation.deeplink
}


function Invoke-Track {
    <#
    .SYNOPSIS
    Plays a track using yt-dlp and ffplay.
    .DESCRIPTION
    This function takes a formatted playlist item (as returned by Format-XMPlaylistItem) and plays the track using yt-dlp to fetch the audio stream and ffplay to play it.
    .PARAMETER Item
    The formatted playlist item to play.
    .PARAMETER batch
    If specified, the track will be played using the batch file (ytaudio.bat) rather than using Powershell inline method.
    .EXAMPLE
    $item = $(Get-XMPlaylist).results | Select-Object -First 1 | Format-XMPlaylistItem
    Invoke-Track -Item $item
    .EXAMPLE
    $playlist = $(Get-XMPlaylist).results | ForEach-Object { $_ | Format-XMPlaylistItem }
    $playlist | ForEach-Object { $_ | Invoke-Track -batch }
    #>


    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$Item,

        [switch] $batch

    )
            if (-not $Item.Link) {
                Write-Warning "No link available for $($Item.Artist) - $($Item.Title). Skipping."
                return
            }

            if ($batch) {
                # example -- $playlist | ForEach-Object {$_ | Invoke-XMTrack -batch}
                Write-Output "[xmplaylist] (batch mode) Playing: $($Item.Artist) - $($Item.Title)"
                # cd to script root
                Set-Location -Path $PSScriptRoot
                .\ytaudio.bat $Item.Link
                return
            }
            

            Write-Output "[xmplaylist] Playing: $($Item.Artist) - $($Item.Title)"
            $DownloaderExe = "yt-dlp.exe"
            $DownloaderArgs = "-f bestaudio -o -"

            # Using Start-Process to handle the pipeline correctly
            $processInfo = New-Object System.Diagnostics.ProcessStartInfo
            $processInfo.FileName = $DownloaderExe
            $processInfo.Arguments = "$DownloaderArgs `"$($Item.Link)`""
            $processInfo.RedirectStandardOutput = $true
            $processInfo.UseShellExecute = $false
            $processInfo.CreateNoWindow = $true

            $process = New-Object System.Diagnostics.Process
            $process.StartInfo = $processInfo
            $process.Start() | Out-Null

            # Pipe the output to ffplay
            $ffplayInfo = New-Object System.Diagnostics.ProcessStartInfo
            $ffplayInfo.FileName = "ffplay"
            #$ffplayInfo.Arguments = "-loglevel quiet -nodisp -autoexit -i -"
            $ffplayInfo.Arguments = "-nodisp -autoexit -i -"
            $ffplayInfo.RedirectStandardInput = $true
            $ffplayInfo.UseShellExecute = $false
            $ffplayInfo.CreateNoWindow = $true

            $ffplayProcess = New-Object System.Diagnostics.Process
            $ffplayProcess.StartInfo = $ffplayInfo
            $ffplayProcess.Start() | Out-Null

            # Redirect the output of yt-dlp to ffplay's input
            $process.StandardOutput.BaseStream.CopyTo($ffplayProcess.StandardInput.BaseStream)
            $process.StandardOutput.Close()
            $ffplayProcess.StandardInput.Close()

            # Wait for both processes to finish
            $process.WaitForExit()
            $ffplayProcess.WaitForExit()


}

Export-ModuleMember -Function Get-Station, Get-Playlist, Start-Playlist, Show-Player, Format-PlaylistItem, Invoke-Track
