<#
    Module: XmPlaylist
    Description: PowerShell module for accessing xmplaylist.com API
    Date: 2025-09-24
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
    

    .NOTES
    https://xmplaylist.com/api/station

    #>


    $url = "https://xmplaylist.com/api/station"
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" }
    

    $output = @()

    $response.results | ForEach-Object {
        $station = [PSCustomObject]@{
            Number            = $_.number
            Name              = $_.name
            Deeplink          = $_.deeplink
            ShortDescription  = $_.shortdescription

        }
        $output += $station
}

    return $output
}

function Get-Playlist{
    <#
    .SYNOPSIS
    Gets recently played tracks for a specified SiriusXM channel or the general feed.

    .DESCRIPTION
    This function calls the xmplaylist.com API endpoint `/api/station/{channel}` to fetch metadata and playlist information for the specified SiriusXM channel. If no channel is specified, it retrieves a general feed.

    .PARAMETER Channel
    The 'deeplink' name of the SiriusXM channel (e.g., "siriusxmhits1"). Use Get-XMStation to retrieve a list of available channels.

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
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$Channel
        )


    $url = "https://xmplaylist.com/api/feed"

    if ($Channel) {
    $url = "https://xmplaylist.com/api/station/$Channel"
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" }
        #return $response
    } catch {
        Write-Error "Failed to retrieve data for channel '$Channel'. $_"
    }

    Format-PlaylistTable($response)
}

function Get-Links{
    <#
    .SYNOPSIS
    Extracts 'links' properties from a JSON response, with optional filtering by site name.

    .DESCRIPTION
    This function takes a JSON object (returned from xmplaylist.com API) and extracts all 'links' properties. You can optionally filter the results by site name.

    .PARAMETER JsonResponse
    The JSON object returned from an API call.

    .PARAMETER Site
    Optional. The site name to filter links by (e.g., "youtube", "spotify"). If not provided, all links are returned.

    .EXAMPLE
    Get-XMPlaylist siriusxmhits1 | Get-XMLinks

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$JsonResponse,

        [Parameter(Mandatory = $false)]
        [string]$Site
    )

    $links = @()

        if ($JsonResponse.PSObject.Properties['links']) {
            foreach ($link in $JsonResponse.links) {
                if ($Site) {
                    if ($link.site -eq $Site) {
                        $links += $link
                    }
                } else {
                    $links += $link
                }
            }
        }
    

    return $links
}

function Format-PlaylistTable {
    <#
    .SYNOPSIS
    Formats the playlist JSON response into a table with Artist, Title, Channel, and Link.

    .DESCRIPTION
    This function takes a JSON response from the xmplaylist.com API and formats it into a more
    human-readable table with columns for Artist, Title, Channel, and Link.

    .PARAMETER JsonResponse
    The JSON object returned from an API call.

    .PARAMETER Site
    Optional. The site name to filter links by (e.g., "youtube", "spotify"). Default is "youtube".


    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$JsonResponse,

        [Parameter(Mandatory = $false)]
        [string]$Site = "youtube"
        )

        $output = @()

        $JsonResponse.results | ForEach-Object {
            $Channel = if ($_.channelid) { $_.channelid } else { $JsonResponse.channel.deeplink.ToLower() }

            $object = [PSCustomObject]@{
                Artist    = $_.track.artists -join ', '
                Title     = $_.track.title
                Channel = $Channel
                Link      = Get-Links $_ -Site $Site | Select-Object -ExpandProperty url
            }

            $output += $object
        }



    return $output

}

function Start-Playlist {

    <#
    .SYNOPSIS
    Plays a playlist of tracks using yt-dlp and ffplay.
    .DESCRIPTION
    This function takes a playlist object (with Artist, Title, Channel, and Link properties) as input and plays it using the specified downloader.
    .PARAMETER Playlist
    The playlist object to play. This should be a custom object with properties: Artist, Title, Channel, and Link.
    .PARAMETER DownloaderExe
    The youtube downloader executable to use (default is "yt-dlp.exe").
    .PARAMETER DownloaderArgs
    Additional arguments to pass to the downloader (default is "-f bestaudio -o -").
    .EXAMPLE
    Get-XMPlaylist siriusxmhits1 | Start-XMPlaylist
    This example retrieves the playlist for the "siriusxmhits1" channel and starts playing it.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$Playlist,

        [Parameter(Mandatory = $false)]
        [string]$DownloaderExe="yt-dlp.exe",

        [Parameter(Mandatory = $false)]
        [string]$DownloaderArgs = "-f bestaudio -o -"


         )


    begin {        

        Write-Verbose "Starting playlist playback..."

        #if verbose switch is set, do not redirect output
        $redirect = if ($PSBoundParameters['Verbose'])  {''} else {'2>NUL'}

        if (-not (Get-Command $DownloaderExe -ErrorAction SilentlyContinue)) {
            Write-Error "$DownloaderExe not found. Please ensure it is installed and available in the system PATH."
            return
        }
    }

    process {   

        Write-Output "[xmplaylist] Playing: $($Playlist.Artist) - $($Playlist.Title) @ $($Playlist.Channel)"  
        $(cmd /c "$DownloaderExe $DownloaderArgs `"$($Playlist.Link)`" $redirect | ffplay -nodisp -autoexit -i - $redirect")
        #cmd /c "$DownloaderExe $DownloaderArgs `"$($Playlist.Link)`" $redirect | ffplay -loglevel quiet -nodisp -autoexit -i - 1>NUL 2>NUL"
        }

    end {
        Write-Verbose "Finished processing playlist."
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

    $stationList = Get-Station
    $selectedStation = $stationList | Out-GridView -Title "Available Stations" -PassThru
    $selectedStation.deeplink | Get-Playlist | Start-Playlist
}

Export-ModuleMember -Function Get-Station, Get-Playlist, Start-Playlist, Show-Player
