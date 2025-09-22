function Get-XMPStations {
    <#
    .SYNOPSIS
    Retrieves a list of all SiriusXM stations from xmplaylist.com.

    .DESCRIPTION
    This function calls the xmplaylist.com API endpoint `/api/station` to fetch a list of all available SiriusXM stations.

    .EXAMPLE
    Get-XMPStations

    .NOTES
    Author: Dan MacCormac
    Module: XmPlaylist
    API Reference: https://xmplaylist.com/api/documentation
    #>

    $url = "https://xmplaylist.com/api/station"
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylist" }
    return $response
}

function Get-XMPFeed {
    <#
    .SYNOPSIS
    Retrieves the latest feed of songs played on SiriusXM stations from xmplaylist.com.

    .DESCRIPTION
    This function calls the xmplaylist.com API endpoint `/api/feed` to fetch the latest songs played on all SiriusXM stations.

    .EXAMPLE
    Get-XMPFeed

    .NOTES
    Author: Dan MacCormac
    Module: XmPlaylist
    API Reference: https://xmplaylist.com/api/documentation
    #>

    $url = "https://xmplaylist.com/api/feed"
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylist" }
    return $response
}

function Get-XMPChannel {
    <#
    .SYNOPSIS
    Retrieves data for a specific SiriusXM channel from xmplaylist.com.

    .DESCRIPTION
    This function calls the xmplaylist.com API endpoint `/api/station/{channel}` to fetch metadata and playlist information for the specified SiriusXM channel.

    .PARAMETER Channel
    The name of the SiriusXM channel (e.g., "alt-nation", "the-heat", "octane").

    .EXAMPLE
    Get-XMPChannel -Channel "alt-nation"

    .NOTES
    Author: Dan MacCormac
    Module: XmPlaylist
    API Reference: https://xmplaylist.com/api/documentation
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Channel
    )

    $url = "https://xmplaylist.com/api/station/$Channel"
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "XmPlaylist" }
        return $response
    } catch {
        Write-Error "Failed to retrieve data for channel '$Channel'. $_"
    }
}


function Get-XMPLinksFromResponse {
    <#
    .SYNOPSIS
    Extracts 'links' attributes from a JSON response, optionally filtered by site name.

    .DESCRIPTION
    This function takes a JSON object (returned from xmplaylist.com API) and extracts all 'links' properties. You can optionally filter the results by site name.

    .PARAMETER JsonResponse
    The JSON object returned from an API call.

    .PARAMETER Filter
    Optional site name to filter the links by (e.g., "spotify", "applemusic").

    .EXAMPLE
    $response = Get-XMPChannel -Channel "altnation"
    Get-XMPLinksFromResponse -JsonResponse $response

    .EXAMPLE
    Get-XMPChannel pop2k | Get-XMPLinksFromResponse -Filter "youtube" | Select-Object -ExpandProperty url

    .NOTES
    Author: Dan MacCormac
    Module: XmPlaylist
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$JsonResponse,

        [string]$Filter
    )

    $links = @()

    foreach ($item in $JsonResponse.results) {
        if ($item.PSObject.Properties['links']) {
            foreach ($link in $item.links) {
                if ($Filter) {
                    if ($link.site -eq $Filter) {
                        $links += $link
                    }
                } else {
                    $links += $link
                }
            }
        }
    }

    return $links
}


Export-ModuleMember -Function Get-XMPStations, Get-XMPFeed, Get-XMPChannel, Get-XMPLinksFromResponse
