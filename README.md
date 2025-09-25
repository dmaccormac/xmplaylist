
# XmPlaylist

## Overview

**XmPlaylist** is a PowerShell module that provides functions to interact with the [xmplaylist.com API](https://xmplaylist.com/api/documentation). It allows users to retrieve useful data from API responses such as SiriusXM station data and recently played tracks.

## Installation

1. Download and extract the module folder.
2. Open PowerShell and import the module:
   ```powershell
   Import-Module "Path\To\XmPlaylist\XmPlaylist.psm1"
   ```


## Functions

### `Get-XMStation`
Retrieves a list of all available SiriusXM stations.

```powershell
Get-XMStation
```

---

### `Get-XMPlaylist`
Retrieves recently played tracks for feed or channel.

Get recently played tracks for all channels (feed).
```powershell
Get-XMPlaylist 
```

Get recently played tracks for siriusxmhits1 channel.
```powershell
Get-XMPlaylist -Channel "siriusxmhits1"
```

---

### Format-XMPlaylistTable

Formats the playlist JSON response into a table with Artist, Title, Channel, and Link.

Get recently played tracks for all channels and show default links (youtube).
```powershell
Get-XMPlaylist | Format-XMPlaylistTable
```

Get recently played for siriusxmhits1 and show spotify links.
```powershell
Get-XMPlaylist siriusxmhits1 | Format-XMPlaylistTable -Site spotify
```

## Author
**Dan MacCormac <dmaccormac@gmail.com>**

---