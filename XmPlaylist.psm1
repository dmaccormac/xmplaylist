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
    Retrieves a list of all SiriusXM stations.

    .EXAMPLE
    $stations = Get-XMStation | Select-Object name, deeplink
    Stores the list of stations with their names and deeplinks in the `$stations` variable for further processing.

    .NOTES
    https://xmplaylist.com/api/station

    #>

    $url = "https://xmplaylist.com/api/station"
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" }
    return $response.results

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
    Get-XMPlaylist siriusxmhits1 # Retrieves recently played tracks for the "siriusxmhits1" channel

    .EXAMPLE
    Get-XMPlaylist -Channel "siriusxmhits1/newest" # Retrieves the newest tracks for the "siriusxmhits1" channel

    .EXAMPLE
    Get-XMPlaylist -Channel "siriusxmhits1/most-heard" # Retrieves the most-heard tracks for the "siriusxmhits1" channel

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


function Get-PlaylistItemData
{
    <#
    .SYNOPSIS
    Extracts key information from a playlist item.

    .DESCRIPTION
    This function takes a playlist item object (as returned by Get-XMPlaylist) and extracts key information such as artist, title, link, and timestamp.
    It returns a custom PowerShell object with these properties for easier consumption.

    .PARAMETER Item
    The playlist item object to process.

    .PARAMETER Site
    The site to extract the link from (e.g., 'youtube', 'spotify'). Default is 'youtube'.

    .EXAMPLE
    $itemData = Get-PlaylistItemData -Item $playlistItem -Site 'youtube'

    Extracts key information from the given playlist item and stores it in the `$itemData` variable.

    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Item,

        [Parameter(Mandatory = $false)]
        [string]$Site = 'youtube'  # Default site for link extraction (e.g., 'youtube', 'spotify')
    )

    $artist = if ($Item.track.artists) { $Item.track.artists -join ', ' } else { 'Unknown' }
    $title = if ($Item.track.title) { $Item.track.title } else { 'Unknown' }
    $time = if ($Item.timestamp) { ([datetime]::Parse($Item.timestamp)).ToLocalTime() } else { 'Unknown' }

    $link = if ($Item.links) { ($Item.links | Where-Object { $_.site -eq $Site } | Select-Object -First 1).url } else { $null }

    return [PSCustomObject]@{
        Artist    = $artist
        Title     = $title
        Link      = $link
        Timestamp = $time
    }

}

function Format-Playlist {
    <#
    .SYNOPSIS
    Formats a playlist into a custom object with artist, title, link and timestamp.

    .DESCRIPTION
    This function takes a playlist item object (as returned by Get-XMPlaylist) and extracts key information such as artist, title, link, and timestamp.
    It returns a custom PowerShell object with these properties for easier consumption.

    .PARAMETER Item
    The playlist item object to process.

    .PARAMETER Site
    The site to extract the link from (e.g., 'youtube', 'spotify'). Default is 'youtube'.

    .EXAMPLE
    Get-Playlist siriusxmhits1 | Format-XMPlaylist

    Create $playlist item containing recently played items for siriusxmhits1 station.


    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$Items,

        [Parameter(Mandatory = $false)]
        [string]$Site = 'youtube'  # Default site for link extraction (e.g., 'youtube', 'spotify')
    )

    # Process each item in the collection
    begin {
        $formattedItems = @()
    }
    process {
        foreach ($Item in $Items) {
            $formattedItem = Get-PlaylistItemData -Item $Item -Site $Site
            $formattedItems += $formattedItem

          
        }
    }
    end {
        return $formattedItems
     }
}

function Test-Dependency {
    <#
    .SYNOPSIS   
    Checks if a required command-line dependency is installed.
    .DESCRIPTION
    This function checks if a specified command-line tool is available in the system PATH.
    If the tool is not found, it returns $false and displays a warning message.
    .PARAMETER CommandName
    The name of the command-line tool to check (e.g., 'yt-dlp.exe
    .EXAMPLE
    Test-Dependency -CommandName 'yt-dlp.exe'
    Checks if 'yt-dlp.exe' is installed and available in the system PATH.
    #>

    [CmdletBinding()]
    param (
        [string]$CommandName
    )

    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        Write-Warning "$CommandName is not installed."
        return $false
    }
    return $true
}

function Invoke-DependencyInstall {
    <#
    .SYNOPSIS
    Installs a required command-line dependency using winget.
    .DESCRIPTION
    This function attempts to install a specified command-line tool using the Windows Package Manager (winget).
    It prompts the user for confirmation before proceeding with the installation.
    .PARAMETER CommandName
    The name of the command-line tool to install (e.g., 'yt-dlp.exe').
    .PARAMETER WingetId
    The winget package identifier for the tool (e.g., 'yt-dlp.yt-dlp').
    #>

    [CmdletBinding()]
    param (
        [string]$CommandName,
        [string]$WingetId
    )
    Write-Host "Installing $CommandName..."
    winget install $WingetId --silent --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "$CommandName installation successful. Please restart your PowerShell session." 
    } else { 
        Write-Error "Failed to install $CommandName. Please install it manually and ensure it is in your system PATH."

    }

}



function Invoke-Playlist {
    <#
    .SYNOPSIS
    Plays items in a playlist using yt-dlp and ffplay.

    .DESCRIPTION
    This function takes an playlist containing a YouTube link and plays the track using yt-dlp to fetch the audio and ffplay to play it.
    
    .PARAMETER Item
    The formatted playlist item to play.
   
    .PARAMETER Download
    Downloads the audio as an mp3 file instead of playing it.

    .PARAMETER Quiet
    If specified, suppresses yt-dlp and ffplay output.
    
    .EXAMPLE
    Get-Playlist siriusxmhits1 | Invoke-XMPlaylist

    Plays all recently played items for the siriusxmhits1 station. Suppresses output from yt-dlp and ffplay.
    
    .EXAMPLE
    Get-Playlist siriusxmhits1 | Invoke-XMPlaylist -Download

    Saves all recently played items for the siriusxmhits1 station to mp3 files.

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$Items,
        [Parameter(Mandatory = $false)]
        [switch]$Download,
        [Parameter(Mandatory = $false)]
        [switch]$Quiet,
        [Parameter(Mandatory = $false)]
        [string]$Site = 'youtube'  # Playlist site (e.g., 'youtube', 'spotify')
    )

    begin {
        $dependencies = @(
            @{ Name = "yt-dlp.exe"; WingetId = "yt-dlp.yt-dlp" }
            @{ Name = "ffplay.exe"; WingetId = "ffmpeg.ffmpeg" }
            @{ Name = "deno.exe"; WingetId = "denoland.deno" }
        )
        foreach ($dp in $dependencies) {
            if (-not (Test-Dependency -CommandName $dp.Name)) {
                $Choice = Read-Host "$($dp.Name) is required but not installed. Would you like to install it now? (Y/N)"
                if ($Choice -eq 'Y' -or $Choice -eq 'y') {
                    Invoke-DependencyInstall -CommandName $dp.Name -WingetId $dp.WingetId
                } else {
                    Write-Error "Cannot proceed without installing $($dp.Name). Exiting."
                    return
                }
            }
        }
        
        $cmdLine = ""
        if ($Download) {
            Write-Host -ForegroundColor Yellow "[xmplaylist] Download mode enabled. Files will be saved as mp3."
            $cmdLine = 'cmd /c "yt-dlp.exe -t mp3 ""{0}"" -o ""{1} - {2}.mp3"""' 
        } else {
            $cmdLine = 'cmd /c "yt-dlp.exe --no-progress -f bestaudio ""{0}"" -o - | ffplay -nodisp -autoexit -i -"' 
        }

        if ($Quiet) { $cmdLine += ' *> $null'}

    }

    

    process {
        foreach ($Item in $Items) {
            
            $current = Get-PlaylistItemData -Item $Item -Site $Site
            $artist = $current.Artist
            $title = $current.Title
            $link = $current.Link


            
            # Check if link is available
            if (-not $link) {
                Write-Warning "[xmplaylist] No link available for $($artist) - $($title). Skipping."
                continue
            }

            Write-Host -ForegroundColor Green "[xmplaylist] $($artist) - $($title)"
         
            $formattedCmd = if ($Download) {
                $cmdLine -f $link, $artist, $title
            } else {
                $cmdLine -f $link
            }

            Invoke-Expression $formattedCmd

        }
    }
    end {   
        Write-Host -ForegroundColor Green "[xmplaylist] Completed processing all items."
    }

}

function Show-PlaylistHelper{
    <#
    .SYNOPSIS
    Displays a grid view of available SiriusXM stations for user selection and plays the selected station's playlist.

    .DESCRIPTION
    This function retrieves a list of all SiriusXM stations using Get-XMStation, displays them in an interactive grid view for user selection, and then fetches and plays the playlist for the selected station using Get-XMPlaylist and Invoke-XMPlaylist.

    .PARAMETER Download
    If specified, downloads the audio as mp3 files instead of playing them.

    .EXAMPLE
    Show-PlaylistHelper
    

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$Download
    )


    $stationList = Get-Station | Select-Object number, name, shortdescription, longdescription, deeplink
    $selectedStation = $stationList | Out-GridView -Title "XMPaylist Helper" -PassThru
    if ($selectedStation)
    {
        Get-Playlist -Channel $selectedStation.deeplink | Invoke-Playlist -Download:$Download -Quiet
    }
}

function Test-Playlist {

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Channel
    )


    $url = "https://xmplaylist.com/api/station/$Channel"
    while ($url) 
    {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" }
        $response.results  | Format-Playlist | Out-Host
        $url = $response.next
        
        Read-Host "Press Enter to load more, or Ctrl+C to exit"
        Write-Output "`nLoading more tracks...`n"

    }
}

Export-ModuleMember -Function Get-Station, Get-Playlist, Format-Playlist, Invoke-Playlist, Show-PlaylistHelper, Test-Playlist