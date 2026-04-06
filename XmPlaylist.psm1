<#
    Module: XmPlaylist
    Description: PowerShell module for accessing xmplaylist.com API
    Date: 2026.04.05
    Author: Dan MacCormac <dmaccormac@gmail.com>
    Website: https://github.com/dmaccormac/XmPlaylist
    API Reference: https://xmplaylist.com/api/documentation
#>

function Get-Station {
    <#
    .SYNOPSIS
    Retrieves a list of SiriusXM stations from the xmplaylist.com API.
    .DESCRIPTION
    This function calls the xmplaylist.com API to fetch a list of SiriusXM stations.
    It supports optional filtering by station name, number, or description, and can return either a formatted list of stations or the raw API response.
    .PARAMETER Filter
    Optional search term to filter stations by Name, Number or Description. 
    .PARAMETER Exact
    Used in conjunction with -Filter. If specified, performs an exact match search instead of a wildcard search.
    .PARAMETER Raw
    If specified, returns the raw API response without conversion or filtering.
    .EXAMPLE
    Get-Station -Filter rock
    Retrieves stations that match 'rock' in any of the searchable fields.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 0)]
        [string]$Filter,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [switch]$Exact = $false,
        [Parameter(Mandatory = $false)]
        [switch]$Raw = $false

    )

    begin {
        $url = "https://xmplaylist.com/api/station"
    }

    process {
        try {
            $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" } -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to retrieve station list: $_"
            return
        }

        if ($Raw) { 
            return $response 
        } 

        $items = ConvertFrom-ApiStation -Items $response  
        
        if ($Filter) {
            if ($Exact) {
                $items = $items | Where-Object { 
                    $_.Name -eq $Filter -or 
                    $_.Number -eq $Filter -or
                    $_.Deeplink -eq $Filter -or 
                    $_.Description -eq $Filter -or 
                    $_.LongDescription -eq $Filter
                }
            } else {
                $items = $items | Where-Object { 
                    $_.Name -like "*$Filter*" -or 
                    $_.Number -like "*$Filter*" -or 
                    $_.Deeplink -like "*$Filter*" -or 
                    $_.Description -like "*$Filter*" -or 
                    $_.LongDescription -like "*$Filter*"
                }
                
            }
            return $items
        }

        return $items | Select-Object -Property Number, Name, Description

    }

}

function Get-Playlist{
    <#
    .SYNOPSIS
    Retrieves a list of recently played tracks from SiriusXM.
    .DESCRIPTION
    This function calls the xmplaylist.com API to fetch recently played tracks for a specified SiriusXM channel.
    It supports pagination to retrieve multiple pages of results, filtering by search term, and can return either a formatted list of tracks or the raw API response.
    .PARAMETER Channel
    The channel to retrieve the playlist for. This can be the channel's name, number, or deeplink. If not specified, it retrieves the default feed.
    Also accepts pipeline input, allowing you to pass station objects directly from Get-Station. 
    .PARAMETER Link
    The site to extract the link from (e.g., 'youtube', 'spotify'). Default is 'youtube'.
    Available sites: amazon, amazonMusic, appleMusic, deezer, itunes, pandora, soundcloud, spotify, tidal, youtube, youtubeMusic, qobuz.  
    .PARAMETER Size
    The number of tracks to retrieve. Default is 24 (one page). 
    Maximum is 100 for channel playlists and 1000 for the default feed. 
    .PARAMETER Raw
    If specified, returns the raw API response without conversion.
    .PARAMETER Filter
    Optional search term to filter tracks by Artist, Title, Channel, Link, or Timestamp.
    .PARAMETER Exact
    If specified, performs an exact match search instead of a wildcard search.
    .EXAMPLE
    Get-XMPlaylist siriusxmhits1
    Retrieves recently played tracks for the "SiriusXM Hits 1" channel    
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 0)]
        $Channel,
        [Parameter(Mandatory = $false)]
        [string]$Link = 'youtube',
        [Parameter(Mandatory = $false)]
        [int]$Size = 24,
        [Parameter(Mandatory = $false)]
        [switch]$Raw = $false,
        [Parameter(Mandatory = $false)]
        [string]$Filter,
        [Parameter(Mandatory = $false)]
        [switch]$Exact = $false
        )


    process {
        try 
        {

            if ($Channel -is [string] -or $Channel -is [int])
            {
                $Channel = Get-Station -Filter $Channel -Exact | Select-Object -First 1
                if (-not $Channel) {
                    Write-Error "No station found matching '$Channel'. Please check the channel name/number and try again."
                    return
                }
            }
            
            if ($Channel) { 
                $url = "https://xmplaylist.com/api/station/$($Channel.Deeplink)"                 
                $Max = 100
                
            }
            else { 
                $url = "https://xmplaylist.com/api/feed" 
                $Max = 1000 
            }

            if ($Size -gt $Max) {
                Write-Warning "Size parameter exceeds maximum allowed. Only the first $Max tracks will be retrieved."
                $Size = $Max
            }         

            

            $allResults = @()

            while ($allResults.Count -lt $Size -and $url) 
            {
                $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" }
                            
                if ($Raw) {$allResults += $response} 
                else {$allResults += (ConvertFrom-ApiPlaylist -Items $response -Site $Link)}
                
                $url = $response.next
                Start-Sleep -Milliseconds 200  # To avoid hitting rate limits
            }

            if ($Filter) {
                if ($Exact) {
                    $allResults = $allResults | Where-Object { 
                        $_.Artist -eq $Filter -or 
                        $_.Title -eq $Filter -or 
                        $_.Channel -eq $Filter -or
                        $_.Link -eq $Filter -or 
                        $_.Timestamp -eq $Filter
                    }
                } else {
                    $allResults = $allResults | Where-Object { 
                        $_.Artist -like "*$Filter*" -or 
                        $_.Title -like "*$Filter*" -or 
                        $_.Channel -like "*$Filter*" -or 
                        $_.Link -like "*$Filter*" -or 
                        $_.Timestamp -like "*$Filter*"
                    }
                }
            }
             
        } 
        catch     
        {
            Write-Error "Failed to retrieve data for channel '$Channel'. $_"
        }
        return $allResults | Select-Object -First $Size
    }
}


function ConvertFrom-ApiPlaylist {
    <#
    .SYNOPSIS
    Converts playlist items from API format to a custom object.
    .DESCRIPTION
    This function is used by Get-Playlist to convert the raw API response into a more user-friendly format. It extracts key information such as artist, title, channel, timestamp, and a link for the specified site.
    It returns a custom PowerShell object with selected properties for easier consumption.
    .PARAMETER Item
    The playlist item object to process.
    .PARAMETER Site
    The site to extract the link from (e.g., 'youtube', 'spotify'). Default is 'youtube'.
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$Items,

        [Parameter(Mandatory = $false)]
        [string]$Site = 'youtube' 
    )

    begin {
        $formattedItems = @()
    }
    
    process {
        foreach ($Item in $Items.results) {
            $artist = if ($Item.track.artists) { $Item.track.artists -join ', ' } else { $null }
            $title = if ($Item.track.title) { $Item.track.title } else { $null }
            $time = if ($Item.timestamp) { ([datetime]::Parse($Item.timestamp)).ToLocalTime() } else { $null }
            $channel = if ($Item.channelId) { $Item.channelId} else { ($Items.channel.deeplink).ToLower() }
            $link = if ($Item.links) { ($Item.links | Where-Object { $_.site -eq $Site } | Select-Object -First 1).url } else { $null }

           
            $formattedItem = [PSCustomObject]@{
                PSTypeName = 'XmPlaylist.Track'
                Artist    = $artist
                Title     = $title
                Channel   = $channel
                Link      = $link
                Timestamp = $time
            }
            
            $formattedItems += $formattedItem
        }
    }
    end {
        return $formattedItems | Where-Object { $null -ne $_.Link } # Filter out items without a link
    }
}

function ConvertFrom-ApiStation {
    <#
    .SYNOPSIS
    Converts station items from API format to a custom object.
    .DESCRIPTION
    This function is used by Get-Station to convert the raw API response into a more user-friendly format. It extracts key information such as station number, name, description, and deeplink.
    It returns a custom PowerShell object with selected properties for easier consumption.
    .PARAMETER Item
    The station item object to process.
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$Items
    )

    begin {
        $formattedItems = @()
    }
    process {
        foreach ($Item in $Items.results) {
            $number = if ($Item.number) { $Item.number } else { $null }
            $name = if ($Item.name) { $Item.name } else { $null }
            $description = if ($Item.shortDescription) { $Item.shortDescription } else { $null }
            $longDescription = if ($Item.longDescription) { $Item.longDescription } else { $null }
            $deeplink = if ($Item.deeplink) { $Item.deeplink } else { $null }

            $formattedItem = [PSCustomObject]@{
                Number         = $number
                Deeplink       = $deeplink
                Name           = $name
                Description    = $description
                LongDescription = $longDescription
            }

            $formattedItems += $formattedItem
        }
    }
    end {
        return $formattedItems
    }

}


function Show-Playlist {
    <#
    .SYNOPSIS
    Displays the playlist for a specified SiriusXM channel in the console with pagination.
    .DESCRIPTION
    This function retrieves the playlist for a specified SiriusXM channel using Get-Playlist and displays the formatted playlist items in the console.
    It supports pagination to load more tracks interactively.
    .PARAMETER Channel
    The channel to retrieve the playlist for. This can be the channel's name, number, or deeplink. If not specified, it prompts the user to select a channel from the list.
    Also accepts pipeline input, allowing you to pass a station object directly from Get-Station.
    .PARAMETER Link
    The site to extract the link from (e.g., 'youtube', 'spotify'). Default is 'youtube'.
    .EXAMPLE
    Show-XmPlaylist -Channel "siriusxmhits1"
    Retrieves and displays the playlist for the "siriusxmhits1" channel, allowing the user to load more tracks interactively.
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 0)]
        [object]$Channel,
        [Parameter(Mandatory = $false)]
        [string]$Link = 'youtube'
    )

    
        if (-not $Channel) {
            $Channel = Get-Station | Out-GridView -Title "Select a Channel" -PassThru
            $Channel = $Channel.Number
            if (-not $Channel) { return }
        }

        if ($Channel -is [string] -or $Channel -is [int]) {
            $Station = Get-Station -Filter $Channel -Exact | Select-Object -First 1
            if (-not $Station) {
                Write-Error "No station found matching '$Channel'. Please check the channel name/number and try again."
                return
            }
        }
        elseif ($Channel -is [object] -and $Channel.Deeplink) {
            $Station = $Channel
        }
        else {
            Write-Error "Invalid value for -Channel."
            return
        }

        $url = "https://xmplaylist.com/api/station/$($Station.Deeplink)"

        while ($url) {
            $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylistModule" }
            $response | ConvertFrom-ApiPlaylist -Site $Link | Out-Host
            $url = $response.next

            Read-Host "Press Enter to load more, or Ctrl+C to exit"
            Write-Output "`nLoading more tracks...`n"
        }
}

Export-ModuleMember -Function Get-Station, Get-Playlist, Show-Playlist
