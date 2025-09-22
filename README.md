
# XmPlaylist

## Overview
**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). It allows users to retrieve SiriusXM station data, feed information, and extract useful data from API responses.

## Installation

1. Download and extract the module folder.
2. Open PowerShell and import the module:
   ```powershell
   Import-Module "Path\To\XmPlaylistModule\XmPlaylistModule.psm1"
   ```

## Functions

### `Get-XMPStations`
Retrieves a list of all available SiriusXM stations.

```powershell
Get-XMPStations
```

---

### `Get-XMPFeed`
Get the recently played tracks for all channels.

```powershell
Get-XMPFeed
```

---

### `Get-XMPChannel`
Retrieves data for a specific SiriusXM channel.

```powershell
Get-XMPStationByChannel -Channel "alt-nation"
```

---

### `Get-XMPLinksFromResponse`
Extracts all `links` attributes from a JSON response. Optionally filter by site name.

```powershell
$response = Get-XMPStationByChannel -Channel "alt-nation"

# Get all links
Get-XMPLinksFromResponse -JsonResponse $response

# Get only Spotify links
Get-XMPLinksFromResponse -JsonResponse $response -Filter "spotify"
```

## Author
**Dan MacCormac <dmaccormac@gmai.com>**

---